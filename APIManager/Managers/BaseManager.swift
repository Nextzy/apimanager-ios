//
//  BaseManager.swift
//  APIManager
//
//  Created by Kent Winder on 9/19/17.
//  Copyright © 2017 Thongpak. All rights reserved.
//

import Foundation
import Alamofire

struct ResponseCode {
    static let Success = "200"
    static let ExternalError = "500"
}

struct ResultMessage {
    let title: String?
    let body: String
    let errorCode: String
    
    init(title: String?, body: String) {
        self.title = title
        self.body = body
        self.errorCode = ""
    }
    
    init(title: String?, body: String, errorCode: String) {
        self.title = title
        self.body = body
        self.errorCode = errorCode
    }
}

public class BaseManager {
    var headers = [String: String]()
    
    init() {
        headers.removeAll()
        headers["Content-Type"] = "application/json; charset=utf-8"
    }
    
    func get<Result: Decodable>(url: String, responseType: Result.Type, completion: @escaping (_ result: Result?, _ message: ResultMessage) -> (), failure: @escaping (_ error: ResultMessage) -> ()) {
        self.sendRequest(url: url, httpMethod: .get, responseType: responseType, completion: completion, failure: failure)
    }
    
    func post<Body: Encodable, Result: Decodable>(url: String, body: Body, responseType: Result.Type, completion: @escaping (_ result: Result?, _ message: ResultMessage) -> (), failure: @escaping (_ error: ResultMessage) -> ()) {
        self.sendRequest(url: url, httpMethod: .post, body: body, responseType: responseType, completion: completion, failure: failure)
    }
    
    private func sendRequest<Body: Encodable, Result: Decodable>(url: String, httpMethod: HTTPMethod, body: Body? = nil, responseType: Result.Type, completion: @escaping (_ result: Result?, _ message: ResultMessage) -> (), failure: @escaping (_ error: ResultMessage) -> ()) {
        var parameters: [String: Any]?
        if let unwrappedBody = body {
            let data = try! JSONEncoder().encode(unwrappedBody)
            parameters = try! JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
        }
        self.sendRequest(url: url, httpMethod: httpMethod, parameters: parameters, responseType: responseType, completion: completion, failure: failure)
    }
    
    private func sendRequest<Result: Decodable>(url: String, httpMethod: HTTPMethod, parameters: [String: Any]? = nil, responseType: Result.Type, completion: @escaping (_ result: Result?, _ message: ResultMessage) -> (), failure: @escaping (_ error: ResultMessage) -> ()) {
        Alamofire.request(url, method: httpMethod, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                self.handleResponse(response, responseType: responseType, completion: completion, failure: failure, secretKeyRenewedCompletion: { () -> () in
                    self.sendRequest(url: url, httpMethod: httpMethod, parameters: parameters, responseType: responseType, completion: completion, failure: failure)
                })
        }
    }
    
    func upload<Result: Decodable>(url: String, data: Data, formData: [String: String], responseType: Result.Type, completion: @escaping (_ result: Result?, _ message: ResultMessage) -> (), failure: @escaping (_ error: ResultMessage) -> ()) {
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(data, withName: "image", fileName: "image.jpg", mimeType: "image/jpeg")
            for (key, value) in formData {
                multipartFormData.append(value.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: key)
            }
        }, usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold,
           to: url,
           method: .post,
           headers: headers) { (encodingResult) in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    self.handleResponse(response, responseType: responseType, completion: completion, failure: failure, secretKeyRenewedCompletion: { () -> () in
                        self.upload(url: url, data: data, formData: formData, responseType: responseType, completion: completion, failure: failure)
                    })
                }
            case .failure(let encodingError):
                print(encodingError)
            }
        }
    }
    
    private func handleResponse<Result: Decodable>(_ response: Alamofire.DataResponse<Any>, responseType: Result.Type, completion: (_ result: Result?, _ message: ResultMessage) -> (), failure: @escaping (_ error: ResultMessage) -> (), secretKeyRenewedCompletion: @escaping () -> ()) {
        var _result: Result?
        var title: String?
        var successMessage: String?
        var errorMessage: String?
        var errorCode = ""
        
        if let _ = response.result.error {
            let handleErrorResult = self.handleError(error: response.result.error!)
            title = handleErrorResult.title
            errorMessage = handleErrorResult.message
            errorCode = handleErrorResult.code
        } else {
            if let data = response.result.value as? Data {
                guard let resultObj = try? JSONDecoder().decode(Response<Result>.self, from: data) else {
                    errorMessage = "Error initializing object"
                    return
                }
                
                if resultObj.statusCode == ResponseCode.Success {
                    _result = resultObj.result
                    title = resultObj.messageTitle
                    successMessage = resultObj.messageBody
                } else {
                    title = resultObj.messageTitle
                    if let _ = resultObj.messageBody {
                        errorMessage = resultObj.messageBody!
                    } else {
                        if let _ = resultObj.systemErrorMessage {
                            errorMessage = resultObj.systemErrorMessage!
                        }
                    }
                    if (errorMessage ?? "").isEmpty {
                        errorMessage = "Error occurred with code " + resultObj.statusCode
                    }
                    
                    errorCode = resultObj.statusCode
                }
            }
        }
        
        if let _ = errorMessage {
            failure(ResultMessage(title: title, body: errorMessage!, errorCode: errorCode))
        } else {
            completion(_result, ResultMessage(title: title, body: successMessage ?? ""))
        }
    }
    
    
    private func handleError(error: Error) -> (message: String, code: String, title: String) {
        // for all error code
        // https://developer.apple.com/library/mac/documentation/Networking/Reference/CFNetworkErrors/index.html#//apple_ref/c/tdef/CFNetworkErrors
        var title = ""
        var message = ""
        
        switch Int32(error._code) {
        case CFNetworkErrors.cfurlErrorNotConnectedToInternet.rawValue:
            title = "Network Error"
            message = NSLocalizedString("Not connected to the Internet", comment: "")
        case CFNetworkErrors.cfNetServiceErrorTimeout.rawValue:
            title = "Network Error"
            message = NSLocalizedString("Network service timeout", comment: "")
        default:
            message = error.localizedDescription
        }
        
        return (message, String(error._code), title)
    }
}

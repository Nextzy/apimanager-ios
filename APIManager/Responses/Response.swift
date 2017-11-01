//
//  Response.swift
//  APIManager
//
//  Created by Kent Winder on 9/19/17.
//  Copyright © 2017 Thongpak. All rights reserved.
//

import Foundation

struct Response<T: Decodable>: Decodable {
    let statusCode: String
    let messageTitle: String?
    let messageBody: String?
    let systemErrorMessage: String?
    var result: T?
    
    enum CodingKeys: String, CodingKey {
        case statusCode = "status_code"
        case messageTitle = "message_title"
        case messageBody = "message_body"
        case systemErrorMessage = "system_error_message"
        case result = "result"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        statusCode = try container.decode(String.self, forKey: .statusCode)
        messageTitle = try container.decode(String.self, forKey: .messageTitle)
        messageBody = try container.decode(String.self, forKey: .messageBody)
        systemErrorMessage = try container.decode(String.self, forKey: .systemErrorMessage)
        result = try container.decode(T.self, forKey: .result)
    }
}

//{
//    "status_code": "",
//    "message_title": "",
//    "message_body": "",
//    "system_error_message": "",
//    "result": {
//        "user_id": "1",
//        "user_name": "",
//        "first_name": "",
//        "last_name": "",
//        "tel": "",
//        "address": {
//
//        }
//    }
//}


//
//  DemoManager.swift
//  APIManager
//
//  Created by Kent Winder on 9/21/17.
//  Copyright © 2017 Thongpak. All rights reserved.
//

import Foundation

class DemoManager: BaseManager {
    func signIn(withUsername username: String, andPassword password: String, completion: @escaping (_ accountId: String?) -> (), failure: @escaping (_ error: ResultMessage) -> ()) {
        var request = AccountIdRequest()
        request.username = username
        request.password = password
        
        let url = "\(Config.apiUrl)/user/signin"
        super.post(url: url, body: request, responseType: AccountResponse.self, completion: { result, _ in
            var accountId: String?
            if let _ = result {
                accountId = result!.accountId
                let defaults = UserDefaults.standard
                defaults.set(accountId, forKey: Constants.UserDefaultKeys.accountId)
                //Get User Info
                self.getUserInfo(completion: { (userInfo) in
                    completion(accountId)
                }, failure: failure)
            } else {
                completion(accountId)
            }
            completion(accountId)
        }, failure: failure)
    }
}

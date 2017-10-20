//
//  DemoPostRequest.swift
//  APIManager
//
//  Created by Kent Winder on 9/21/17.
//  Copyright © 2017 Thongpak. All rights reserved.
//

import Foundation

struct DemoPostRequest: Encodable {
    var username: String?
    var password: String?
    
    init() {}
    
    enum CodingKeys: String, CodingKey {
        case username = "username"
        case password = "password"
    }
}

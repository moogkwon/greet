//
//  InstagramManager.swift
//  GriitChat
//
//  Created by GoldHorse on 8/7/18.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit
import SwiftInstagram

class InstagramManager: NSObject {

    let TOKEN_KEY: String = "accessToken";
    
    public static let shared = InstagramManager()
    
    override init() {
        super.init();
    }
    
    var _token: String? = nil;
    var token: String? {
        set {
            _token = newValue
            UserDefaults.standard.set(_token, forKey: TOKEN_KEY);
        }
        get {
            if (_token == nil) {
                _token = UserDefaults.standard.string(forKey: TOKEN_KEY);
            }
            return _token;
        }
    }
}

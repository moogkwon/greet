//
//  UserKey.swift
//  GriitChat
//
//  Created by GoldHorse on 7/30/18.
//  Copyright © 2018 leo. All rights reserved.
//

import Foundation

class UserKey {
    static let PhoneNumber      = "phoneNumber";
    
    static let IsSignup         = "isSignup";
    static let IsAllowDevice    = "isAllowDevice";
    
    static let Profile_Shared_Key = "ProfileVideoPath";
    
    static let CupStartedTime   = "CupStartedTime";
    static let CupCount         = "CupCount";
    
    static func isHasVideoProfile() -> Bool {
        if (Extern.transMng.userInfo == nil ||
            Extern.transMng.userInfo? ["videoPath"] == nil ||
            Extern.transMng.userInfo? ["videoPath"] as! String == "") {
            return false;
        }
        return true;
        /*let path = UserDefaults.standard.string(forKey: Profile_Shared_Key);
        if (path == nil || !FileManager.default.fileExists(atPath: path!)) {
            return false;
        }
        return true;*/
    }
}

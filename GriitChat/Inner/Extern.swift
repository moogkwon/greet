//
//  File.swift
//  GriitChat
//
//  Created by leo on 15/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import Foundation
import SwiftInstagram


enum LoginMethod {
    case Instagram;
    case Griit;
}

class Extern {
//    static let SVR_URL = "ws://18.188.135.55:8443/center";         //AWS
//    static let SVR_URL = "ws://50.30.46.185:8443/center";         //Server4User

//    static let SVR_URL = "ws://192.168.141.1:8443/center";          //B
    static let SVR_URL = "ws://192.168.42.1:8443/center";         //M
    
    static let KMS_URL = "ws://50.30.46.185:8888/kurento";
    
    static let tmpVideoProfileName = "profile.mov";

    static var isPaused: Bool = false;
    
    static var _transMng: TransMng? = nil;
    static var transMng: TransMng {
        set { _transMng = newValue }
        get {
            if (_transMng == nil) {
                _transMng = TransMng(svrUrl: SVR_URL, kmsUrl: KMS_URL);
            }
            return _transMng!;
        }
    }
    
    static var _cupManager: CupManager? = nil;
    static var cupManager: CupManager {
        set { _cupManager = newValue }
        get {
            if (_cupManager == nil) {
                _cupManager = CupManager();
            }
            return _cupManager!;
        }
    }
    
    /* Databases */
    static let dbMoments = DBMoments();
    static let dbFriends = DBFriends();
    static let dbHistory = DBHistory();
    
    static var mainVC: MainViewController? = nil;
    
    static var isOffline = false;
    
    init() {
    }
    
    static func getMemoryUsage() -> Float {
        return report_memory();
    }
    
    static func getCountryFlag(countryCode: String, phoneNumber: String) -> String {
        let indexStartOfText: String.Index = phoneNumber.index(phoneNumber.startIndex, offsetBy: phoneNumber.count - 10)
        let phoneExt = String(phoneNumber[..<indexStartOfText]);
        
        let country: Country = Country(countryCode: countryCode, phoneExtension: phoneExt);
        return country.flag!
    }
    
    static var selective_navState: SelectiveNavState!;
    static var random_navState: RandomNavState!;
    
    static var chat_userInfo: Dictionary<String, Any>!;
    static var chat_videoPath: String!;
    static var chat_userType: ChatCoreViewController.UserType! = .Callee;
    
    
    
    /// Takes the screenshot of the screen and returns the corresponding image
    ///
    /// - Parameter shouldSave: Boolean flag asking if the image needs to be saved to user's photo library. Default set to 'false'
    /// - Returns: (Optional)image captured as a screenshot
    static open func takeScreenshot(_ shouldSave: Bool = false) -> UIImage? {
        var screenshotImage :UIImage?
        let layer = UIApplication.shared.keyWindow!.layer
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
        guard let context = UIGraphicsGetCurrentContext() else {return nil}
        layer.render(in:context)
        screenshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let image = screenshotImage, shouldSave {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
        return screenshotImage
    }
    
    static func getAspectFitRect(orgSize: CGSize, tgtSize: CGSize) -> CGRect {
        let w1 = orgSize.width;
        let h1 = orgSize.height;
        
        let w2 = tgtSize.width;
        let h2 = tgtSize.height;
        
        let r1 = w1 / h1;
        let r2 = w2 / h2;
        
        if (r1 > r2) {
            let width = w1 * h2 / h1;
            return CGRect(x: (w2 - width) / 2, y: 0, width: width, height: h2);
        } else {
            let height = h1 * w2 / w1;
            return CGRect(x: 0, y: (h2 - height) / 2, width: w2, height: height);
        }
    }
}





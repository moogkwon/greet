//
//  Ext_UIViewController.swift
//  GriitChat
//
//  Created by leo on 24/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import Foundation

extension UIViewController {
    func showMessage(title: String, content: String) {
        let alert = UIAlertController(title: title, message: content, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil);
    }
    func showMessage(title: String, content: String, completion: (() -> Void)?) {
        let alert = UIAlertController(title: title, message: content, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) in
            if (completion != nil) {
                completion?();
            }
        }))
        self.present(alert, animated: true, completion: nil);
    }
    
    func showNetworkErrorMessage(completion: (() -> Void)? = nil) {
        showMessage(title: "Network Error", content: "Network connection failed.", completion: completion);
    }
}

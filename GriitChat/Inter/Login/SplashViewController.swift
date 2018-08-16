//
//  SplashViewController.swift
//  GriitChat
//
//  Created by leo on 13/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController, TransMngLoginDelegate {

    @IBOutlet weak var logoView: UIImageView!
    
//    var isShowedSplash = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backView: GradientView = super.view as! GradientView;
        backView.setBackColors(colors: [UIColor.dodgerBlue.cgColor, UIColor.brightLightBlue.cgColor]);
        
        _ = Extern();
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
        Extern.transMng.loginDelegate = self;
        Extern.transMng.connect();
//        gotoLoginPage();
        
        /*if (isShowedSplash) {
            gotoLoginPage();
        } else {
            isShowedSplash = true;
        }*/
    }
    /*
    override func viewDidAppear(_ animated: Bool) {
        let duration:Double = 3
        UIImageView.animate(withDuration: duration, animations: {
//                self.moveTop(logoView : self.logoView)
            }, completion: {finished in
                self.gotoNextPage()
            }
        )
    }
    
    func moveTop(logoView : UIImageView)
    {
        logoView.center.y -= logoView.center.y/8;
    }*/
    
    func gotoLoginPage() {
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController")
        self.navigationController?.pushViewController(loginVC!, animated: true);
    }
    
    func onConnect(result: Bool) {
        if (!Extern.transMng.isConnected()) {
            showNetworkErrorMessage {
                Extern.transMng.connect();
            }
        } else {
            if (!isAbleToLogin()) {
                self.gotoLoginPage();
            }
        }
    }
    
    func isAbleToLogin() -> Bool {
        if (UserDefaults.standard.object(forKey: UserKey.IsSignup) == nil) {
            return false;
        }
        
        let phoneNumber = UserDefaults.standard.string(forKey: UserKey.PhoneNumber);
        if (phoneNumber == nil) {
            return false;
        }
        
        _ = Extern.transMng.login(phoneNumber: phoneNumber!, photoUrl: nil);
        return true;
    }
    
    func onLogin(result: Int, message: String?) {
        if (result > 0) {
            onAfterLogin();
        } else if (result == -1) {
            //Failed with some error (activate error, online error, ...)
            showMessage(title: "Login Failed", content: message!, completion: {() in
                self.gotoLoginPage();
            });
            UserDefaults.standard.set(nil, forKey: UserKey.IsSignup);
        } else if (result == -2) {
            //Unregistered user.
            self.gotoLoginPage();
        }
    }
    
    func onAfterLogin() {
        UserDefaults.standard.set(true, forKey: UserKey.IsSignup);
        
        if (!UserKey.isHasVideoProfile()) {
            let uploadVC: UploadVideoViewController = self.storyboard?.instantiateViewController(withIdentifier: "UploadVideoViewController") as! UploadVideoViewController;
            self.navigationController?.pushViewController(uploadVC, animated: true);
            return;
        }
        
        if (UserDefaults.standard.object(forKey: UserKey.IsAllowDevice) == nil
            || Extern.transMng.userInfo? ["activated"] as! Int == 0) {
            let allowDevVC = self.storyboard?.instantiateViewController(withIdentifier: "AllowDeviceViewController") as! AllowDeviceViewController;
            
            self.navigationController?.pushViewController(allowDevVC, animated: true);
            return;
        }
        let mainVC: MainViewController!;
        if (Extern.mainVC != nil) {
            mainVC = Extern.mainVC;
            Extern.mainVC?.onInit();
        } else {
            mainVC = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController;
        }
        
        self.navigationController?.pushViewController(mainVC, animated: true);
    }
}

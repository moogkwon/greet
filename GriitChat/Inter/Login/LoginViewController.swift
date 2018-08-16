//
//  LoginViewController.swift
//  GriitChat
//
//  Created by leo on 13/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit
import SwiftInstagram

enum AfterProcessState: Int {
    case Pause = 0;
    case LoginWithInstagram = 1;
    case SignWithGriit = 2;
    case Automatically = 3;
}

class LoginViewController: UIViewController, TransMngLoginDelegate, AKFViewControllerDelegate {

    @IBOutlet weak var imgBack: UIImageView!
    
    @IBOutlet weak var btnLoginInstagram: UIButton!
    
    @IBOutlet weak var btnSigninGriit: UIButton!

    /*
     0: Pause.
     1: Login with Instagram
     2: Sign with griit
     3: Primary State - Login automatically with phoneNumber of userdefault.
    */
    var afterProcess: AfterProcessState = .Pause;
    
    var phoneNumber: String? = nil;
    
    var accountKit: AKFAccountKit? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let backView: GradientView = super.view as! GradientView;
        backView.setBackColors(colors: [UIColor.dodgerBlue.cgColor, UIColor.brightLightBlue.cgColor]);
        self.navigationController?.navigationBar.isHidden = true;
        
        btnLoginInstagram.clipsToBounds = true;
        
        btnLoginInstagram.applyGradient(colours: [UIColor.paleGold.cgColor, UIColor.darkishPink.cgColor, UIColor.darkishPinkTwo.cgColor, UIColor.iris.cgColor], direction: .horizontal, frame: btnLoginInstagram.bounds);
        
        btnLoginInstagram.layer.shadowColor = UIColor.black10.cgColor
        btnLoginInstagram.layer.shadowOpacity = 1
        btnLoginInstagram.layer.shadowOffset = CGSize(width: 0, height: 1)
        btnLoginInstagram.layer.shadowRadius = 4 / 2
        btnLoginInstagram.layer.shadowPath = nil
//        btnLoginInstagram.layer.borderWidth = 1;
//        btnLoginInstagram.layer.borderColor = UIColor.black50.cgColor;
        
        btnSigninGriit.clipsToBounds = true;
        
        UserDefaults.standard.setValue(nil, forKey: UserKey.PhoneNumber);
        UserDefaults.standard.setValue(nil, forKey: UserKey.IsSignup);
        InstagramManager.shared.token = nil;
        
        if accountKit == nil {
            self.accountKit = AKFAccountKit(responseType: AKFResponseType.accessToken)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        
        btnLoginInstagram.layer.cornerRadius = btnLoginInstagram.frame.height / 2;
        btnSigninGriit.layer.cornerRadius = btnSigninGriit.frame.height / 2;
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        imgBack.loadGif(asset: "cup_gif");
        Extern.transMng.loginDelegate = self;
        Extern.mainVC = nil;
        
        self.navigationController?.navigationBar.isHidden = true;
        self.navigationController?.setNavigationBarHidden(true, animated: true);
        
        if (afterProcess == .SignWithGriit) {
            
            //Virtual Login
/*            self.phoneNumber = "+447383199058";
            UserDefaults.standard.set(nil, forKey: UserKey.IsSignup);
            UserDefaults.standard.set(nil, forKey: UserKey.PhoneNumber);
            _ = Extern.transMng.login(phoneNumber: self.phoneNumber!, photoUrl: nil);
*/            //--------------
            
            if (accountKit?.currentAccessToken != nil) {
                accountKit?.requestAccount { (account: AKFAccount?, error: Error?) in
                    //account.emailAddress;
//                    let id = account?.accountID;
//                    let email = account?.emailAddress;
                    if (account?.phoneNumber != nil) {
                        self.phoneNumber = (account?.phoneNumber?.stringRepresentation())!;
                        
                        UserDefaults.standard.set(nil, forKey: UserKey.IsSignup);
                        UserDefaults.standard.set(nil, forKey: UserKey.PhoneNumber);
                        
                        _ = Extern.transMng.login(phoneNumber: self.phoneNumber!, photoUrl: nil);
                    }
                    self.accountKit?.logOut();
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        
        imgBack.remove();
//        afterProcess = .Pause;
    }
    
    @IBAction func onBtnLoginWithInstagram(_ sender: Any) {
        self.afterProcess = .LoginWithInstagram;
        
        if (!Extern.transMng.isConnected()) {
            showMessage(title: "Error." , content: "Network connection failed. I am try to connect again.", completion: {
                Extern.transMng.connect();
            });
        } else {
            Instagram.shared.login(from: navigationController!, success: {
                if (Instagram.shared.isAuthenticated) {
                    self.onInstagramLoginSuccess();
                } else {
                    self.onInstagramLoginFailure();
                }
            }, failure: { error in
                self.showMessage(title: "Instagram Login failed.", content: error.localizedDescription);
            })
        }
    }
    
    func onInstagramLoginSuccess() {
        UserDefaults.standard.setValue(nil, forKey: UserKey.PhoneNumber);
        
        Instagram.shared.user("self", success: { (userInfo: InstagramUser) in
            self.afterProcess = .LoginWithInstagram;
            self.phoneNumber = userInfo.id;
            
            _ = Extern.transMng.login(phoneNumber: userInfo.id, photoUrl: userInfo.profilePicture);
        }, failure: { (error: Error) in
            self.showMessage(title: "Instagram Login failed.", content: error.localizedDescription);
        })
    }
    
    func onInstagramLoginFailure() {
        showMessage(title: "Instagram", content: "Instagram login failed.")
    }
    
    
    @IBAction func onBtnSignGriit(_ sender: Any) {
        accountKit?.logOut();
        
        afterProcess = .SignWithGriit;
        showLoginPhoneViewController();
    }
    
    func onConnect(result: Bool) {
        if (!Extern.transMng.isConnected()) {
            showNetworkErrorMessage();
        }
    }
    
    func onLogin(result: Int, message: String?) {
        accountKit?.logOut();
        
        if (result > 0) {   //Login Success
            onAfterLoginSuccess();
        } else if (result == -1) {
            //Failed with some error (activate error, online error, ...)
            showMessage(title: "Login Failed", content: message!);
            UserDefaults.standard.set(nil, forKey: UserKey.IsSignup);
        } else if (result == -2) {
            //New signup.
            afterProcess = .Pause;
            
            let signupVC: SignupViewController = self.storyboard?.instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController;
            signupVC.phoneNumber = phoneNumber!;
            self.navigationController?.pushViewController(signupVC, animated: true);
        }
    }
    
    func onAfterLoginSuccess() {
        afterProcess = .Pause;
        UserDefaults.standard.set(true, forKey: UserKey.IsSignup);
        UserDefaults.standard.set(phoneNumber, forKey: UserKey.PhoneNumber);
        
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
        
        let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController");
        self.navigationController?.pushViewController(mainVC!, animated: true);
    }
    
    func showLoginPhoneViewController() {
        //SMS Login
        let inputState: String = UUID().uuidString
        let viewController:AKFViewController = (accountKit?.viewControllerForPhoneLogin(with: nil, state: inputState))!
        viewController.enableSendToFacebook = true
        
        self.prepareLoginViewController(viewController)
        self.present(viewController as! UIViewController, animated: true, completion: nil)
        
 /*
        //Email Login
        let inputState: String = UUID().uuidString
        let viewController: AKFViewController = accountKit?.viewControllerForEmailLogin(withEmail: nil, state: inputState)  as! AKFViewController
        self.prepareLoginViewController(viewController)
        self.present(viewController as! UIViewController, animated: true, completion: nil)*/
    }
    
    
    func viewController(_ viewController: UIViewController!, didCompleteLoginWith accessToken: AKFAccessToken!, state: String!) {
        print("Login succcess with AccessToken")
    }
    func viewController(_ viewController: UIViewController!, didCompleteLoginWithAuthorizationCode code: String!, state: String!) {
        print("Login succcess with AuthorizationCode")
    }
    private func viewController(_ viewController: UIViewController!, didFailWithError error: NSError!) {
        print("We have an error \(error)")
    }
    func viewControllerDidCancel(_ viewController: UIViewController!) {
        print("The user cancel the login")
    }
    
    func prepareLoginViewController(_ loginViewController: AKFViewController) {
        
        loginViewController.delegate = self
        loginViewController.enableSendToFacebook = true;
        loginViewController.enableGetACall = true;
        
        loginViewController.setAdvancedUIManager(nil);

        let theme:AKFTheme = AKFTheme.default()
        theme.headerBackgroundColor = UIColor.dodgerBlue
        theme.headerTextColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        theme.iconColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1);
        
        theme.inputBackgroundColor = UIColor.darkSkyBlue.withAlphaComponent(0.8)
        theme.inputTextColor = UIColor.white
        theme.inputBorderColor = UIColor.darkSkyBlue.withAlphaComponent(0.8)
        
        theme.statusBarStyle = .default
        theme.textColor = UIColor(white: 1, alpha: 1)
        theme.titleColor = UIColor(white: 1, alpha: 1)
        
        theme.buttonTextColor = UIColor.darkSkyBlue
        theme.headerTextType = .appName
        theme.backgroundColor = UIColor.dodgerBlue;
        
        /*theme.backgroundColor = UIColor.white;
        theme.titleColor = UIColor(white: 0, alpha: 0.7);
        theme.textColor = UIColor(white: 0, alpha: 0.7);
        theme.inputBackgroundColor = UIColor(white: 0.9, alpha: 1)
        theme.inputTextColor = UIColor(white: 0.4, alpha: 1);
        theme.inputBorderColor = UIColor(white: 0, alpha: 0.3);
        
        theme.buttonBackgroundColor = UIColor.darkSkyBlue.withAlphaComponent(0.8);
        theme.buttonTextColor = UIColor(white: 1, alpha: 0.9);
        theme.buttonBorderColor = UIColor(white: 0.9, alpha: 1)
        
        theme.buttonDisabledBackgroundColor = UIColor(white: 0.9, alpha: 1)
        theme.buttonDisabledTextColor = UIColor.darkSkyBlue.withAlphaComponent(0.8);
        theme.buttonDisabledBorderColor = UIColor(white: 0, alpha: 0.3);*/
        
        theme.buttonBackgroundColor = UIColor(white: 1, alpha: 0.9);
        
        loginViewController.setTheme(theme);
    }
}

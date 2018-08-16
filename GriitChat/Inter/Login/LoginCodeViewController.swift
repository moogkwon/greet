//
//  LoginCodeViewController.swift
//  GriitChat
//
//  Created by leo on 13/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit

class LoginCodeViewController: UIViewController, TransMngLoginDelegate {

    @IBOutlet weak var lblPhoneNumber: UILabel!
    
    @IBOutlet weak var edtCode1: UITextField!
    
    @IBOutlet weak var edtCode2: UITextField!
    
    @IBOutlet weak var edtCode3: UITextField!
    
    @IBOutlet weak var edtCode4: UITextField!
    
    @IBOutlet weak var edtCode5: UITextField!
    
    @IBOutlet weak var edtCode6: UITextField!
    
    var edtCodes: [UITextField]?;
    
    @IBOutlet weak var btnContinue: UIButton!
    
    var phoneNumber: String = "";
    
    var countryCode: String = "";
    
    var strCode: String? = nil;
    
    var afterCheck: Int? = nil;     //1: Signup.    2: Login with phoneNumber.
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Navigation Bar
        self.title = "Login griit"
        
        lblPhoneNumber.text = "+" + phoneNumber;
        
        let backView: GradientView = super.view as! GradientView;
        backView.setBackColors(colors: [UIColor.dodgerBlue.cgColor, UIColor.brightLightBlue.cgColor]);
        
        edtCodes = [edtCode1,
                    edtCode2,
                    edtCode3,
                    edtCode4,
                    edtCode5,
                    edtCode6];
        edtCode1.becomeFirstResponder();
        
        for edtCode in edtCodes! {
            edtCode.backgroundColor = UIColor.darkSkyBlue;
        }
        
        
        //Next Button
        btnContinue.layer.cornerRadius = btnContinue.frame.height / 2;
        btnContinue.clipsToBounds = true;
        btnContinue.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        
        Extern.transMng.loginDelegate = self;
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func onChangeCode(_ sender: Any) {
        let textField: UITextField = sender as! UITextField;
        
        let length: Int = textField.text?.count as! Int;
        if (length > Int(1)) {
            let text: String = textField.text!;
            let indexStartOfText: String.Index = text.index(text.startIndex, offsetBy: 1)
            
            textField.text = String(text[..<indexStartOfText]);
            
            var index = 0;
            for edtCode in edtCodes! {
                if (edtCode == textField && index != (edtCodes?.count)! - 1) {
                    edtCodes! [index + 1].text = String(text[indexStartOfText...]);
                    edtCodes! [index + 1].becomeFirstResponder();
                    break;
                }
                index = index + 1;
            }
            
            return;
        }
        
        var index = 0;
        
        for edtCode in edtCodes! {
            if (edtCode == textField) {
                let text = textField.text!;
                if (text.count == 0 && index != 0) {
                    edtCodes! [index - 1].becomeFirstResponder();
                } else if (text.count == 1 && index != (edtCodes?.count)! - 1) {
//                    edtCodes! [index + 1].becomeFirstResponder();
                }
            }
            index = index + 1;
        }
    }
    
    @IBAction func onBtnResendCode(_ sender: Any) {
        let result = Extern.transMng.sendMessage(msg: ["id": "generateCodeWithPhoneNumber",
                                                       "phoneNumber": phoneNumber]);
        
        if (!result) {
            showNetworkErrorMessage();
        }
    }
    
    @IBAction func onContinue(_ sender: Any) {
        //Check Code...
        
        var code: String = "";
        for edtCode in edtCodes! {
            code += edtCode.text!;
        }
        
        if (code != strCode) {
            showMessage(title: "SMS Error", content: "SMS Code is not same. If you didn't receive message, press Resend SMS Code button.");
            return;
        }
        
        if (afterCheck == 1) {
            //New Signup.
            let signupVC = self.storyboard?.instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController;
            signupVC.phoneNumber = self.phoneNumber;
            
//            self.present(signupVC, animated: true, completion: nil);
            self.navigationController?.pushViewController(signupVC, animated: true);
            btnContinue.isEnabled = true;
        } else {
            login();
        }
    }
    
    func onGenerateCodeWithPhoneNumberResponse(message: Dictionary<String, Any>) {
        let result = message ["result"] as! Int;
        if (result == -1) {
            showMessage(title: "Error", content: message ["message"] as! String);
            return;
        }
        
        let smsCode = message ["code"] as? Int;
        var strSms = String(format: "%d", smsCode!);
        for index in 0 ..< 6 - strSms.count {
            strSms = "0" + strSms;
        }
        self.strCode = strSms;
        
        afterCheck = result;
        showMessage(title: "SMS arrived.", content: strSms);
    }
    
    func login() {
        UserDefaults.standard.set(true, forKey: UserKey.IsSignup);
        UserDefaults.standard.set(phoneNumber, forKey: UserKey.PhoneNumber);
        let result = Extern.transMng.login(phoneNumber: phoneNumber, photoUrl: nil);
        
        if (!result) {
            showNetworkErrorMessage();
        } else {
            btnContinue.isEnabled = false;
        }
    }
    
    /**
     result: 1  Check Device and goto main page.
             2  Upload video.
    */
    func onLogin(result: Int, message: String?) {
        if (result == 1) {
            let allowDevVC = self.storyboard?.instantiateViewController(withIdentifier: "AllowDeviceViewController") as! AllowDeviceViewController;
            
            self.navigationController?.pushViewController(allowDevVC, animated: true);
        } else if (result == 2) {
            let uploadVideoVC = self.storyboard?.instantiateViewController(withIdentifier: "UploadVideoViewController") as! UploadVideoViewController;
            
            self.navigationController?.pushViewController(uploadVideoVC, animated: true);
        } else if (result == -1) {
            //Login Failed.
            showMessage(title: "Login error", content: message!, completion: {
                self.btnContinue.isEnabled = true;
            });
        } else if (result == -2) {
            //Unregistered user.
            //New Signup.
            let signupVC = self.storyboard?.instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController;
            signupVC.phoneNumber = self.phoneNumber;
            
            //            self.present(signupVC, animated: true, completion: nil);
            self.navigationController?.pushViewController(signupVC, animated: true);
            btnContinue.isEnabled = true;
        }
    }
}

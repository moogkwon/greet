//
//  SignupViewController.swift
//  GriitChat
//
//  Created by leo on 13/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit
import SwiftInstagram

class SignupViewController: UIViewController, TransMngLoginDelegate, UITextFieldDelegate  {

    @IBOutlet weak var edtNameBox: UIView!
    @IBOutlet weak var edtBirthdayBox: UIView!
    
    @IBOutlet weak var edtFirstName: UITextField!
    @IBOutlet weak var edtBirthday: UITextField!
    
    @IBOutlet weak var datePickerBox: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var requiredBox: UIView!
    
    @IBOutlet weak var btnFemale: UIButton!
    @IBOutlet weak var imgFemale: UIImageView!
    @IBOutlet weak var lblFemale: UILabel!
    
    @IBOutlet weak var btnMale: UIButton!
    @IBOutlet weak var imgMale: UIImageView!
    @IBOutlet weak var lblMale: UILabel!
    
    @IBOutlet weak var btnLgbtq: UIButton!
    @IBOutlet weak var imgLgbtq: UIImageView!
    @IBOutlet weak var lblLgbtq: UILabel!
    
    @IBOutlet weak var btnSignup: UIButton!
    
    var phoneNumber: String = "";
    
    var instagramUser: InstagramUser? = nil;
    
    //false: Female     true: Male
    var genderOption: Bool? = nil;
    var isCheckLgbtq = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backView: GradientView = super.view as! GradientView;
        backView.setBackColors(colors: [UIColor.dodgerBlue.cgColor, UIColor.brightLightBlue.cgColor]);
        
        edtNameBox.backgroundColor = UIColor.darkSkyBlue;
        edtNameBox.clipsToBounds = true;
        
        edtFirstName.backgroundColor = UIColor.darkSkyBlue;
        edtFirstName.becomeFirstResponder();
        edtFirstName.borderStyle = .none
        
        edtFirstName.attributedPlaceholder = NSAttributedString(string: "First Name", attributes: [NSAttributedStringKey.foregroundColor: UIColor.init(white: 1, alpha: 0.3)])
        
        edtBirthdayBox.backgroundColor = UIColor.darkSkyBlue;
        edtBirthdayBox.clipsToBounds = true;
        
        edtBirthday.backgroundColor = UIColor.darkSkyBlue;
        edtBirthday.borderStyle = .none
        
        edtBirthday.attributedPlaceholder = NSAttributedString(string: "Birthday", attributes: [NSAttributedStringKey.foregroundColor: UIColor.init(white: 1, alpha: 0.3)])
        
        edtFirstName.delegate = self
        edtBirthday.delegate = self;
        
        datePicker.addTarget(self, action: #selector(SignupViewController.datePickerValueChanged), for: UIControlEvents.valueChanged)
        
        datePickerBox.isHidden = true;
        
        
        self.navigationController?.navigationBar.isHidden = false;
        
        navigationController?.navigationBar.barTintColor = UIColor.dodgerBlue;
        
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white];
        
        
        self.imgMale.image = UIImage(named: "male_gray");
        self.btnMale.alpha = 0.5;
        self.lblMale.alpha = 0.5;
        
        self.imgLgbtq.image = UIImage(named: "LGBTQ_gray");
        self.btnLgbtq.alpha = 0.5;
        self.lblLgbtq.alpha = 0.5;
        
        Extern.transMng.loginDelegate = self;
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        view.addGestureRecognizer(tap);
        
        if (InstagramManager.shared.token != nil) {
            Instagram.shared.user("self", success: { (userInfo: InstagramUser) in
                self.edtFirstName.text = userInfo.username;
                self.instagramUser = userInfo;
            }, failure: { (error: Error) in
                self.showMessage(title: "Instagram Login failed.", content: error.localizedDescription);
            })
        } else {
            edtFirstName.becomeFirstResponder();
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        
        edtNameBox.layer.cornerRadius = edtNameBox.frame.height / 2;
        edtBirthdayBox.layer.cornerRadius = edtBirthdayBox.frame.height / 2;
        
        //Spin
        requiredBox.layer.cornerRadius = requiredBox.frame.height / 2;
        requiredBox.clipsToBounds = true;
        btnFemale.layer.cornerRadius = btnFemale.frame.height / 2;
        btnFemale.clipsToBounds = true;
        btnMale.layer.cornerRadius = btnMale.frame.height / 2;
        btnMale.clipsToBounds = true;
        btnLgbtq.layer.cornerRadius = btnLgbtq.frame.height / 2;
        btnLgbtq.clipsToBounds = true;
        
        //Sign up button
        btnSignup.layer.cornerRadius = btnSignup.frame.height / 2;
        btnSignup.clipsToBounds = true;
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func onTouchBirthday(_ sender: Any) {
        self.view.endEditing(true)
        showDatePickerBox(isShow: true);
    }
    
    @objc func datePickerValueChanged (datePicker: UIDatePicker) {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd"
        
        let dateValue = dateFormatterGet.string(from: datePicker.date)
        
        DispatchQueue.main.async {
            self.edtBirthday.text = dateValue;
        }
        debugPrint(dateValue);
    }
    
    @IBAction func onOutsideClick(_ sender: Any) {
        showDatePickerBox(isShow: false);
    }
    
    func showDatePickerBox(isShow: Bool) {
        datePickerBox.isHidden = false;
        datePickerBox.alpha = isShow ? 0 : 1;
        
        UIView.animate(withDuration: 0.5, animations: {
            self.datePickerBox.alpha = isShow ? 1 : 0;
        }) { (result: Bool) in
            self.datePickerBox.isHidden = !isShow;
            self.datePickerBox.alpha = 1;
        }
    }
    
    @IBAction func onBtnFemale(_ sender: Any) {
        self.imgFemale.image = UIImage(named: "female");
        self.btnFemale.alpha = 1;
        self.lblFemale.alpha = 1;
        
        self.imgMale.image = UIImage(named: "male_gray");
        self.btnMale.alpha = 0.5;
        self.lblMale.alpha = 0.5;
        
        self.genderOption = false;
    }
    
    @IBAction func onBtnMale(_ sender: Any) {
        self.imgFemale.image = UIImage(named: "female_gray");
        self.btnFemale.alpha = 0.5;
        self.lblFemale.alpha = 0.5;
        
        self.imgMale.image = UIImage(named: "male");
        self.btnMale.alpha = 1;
        self.lblMale.alpha = 1;
        
        self.genderOption = true;
    }
    
    @IBAction func onBtnLgbtq(_ sender: Any) {
        isCheckLgbtq = !isCheckLgbtq;
        if (isCheckLgbtq) {
            self.imgLgbtq.image = UIImage(named: "LGBTQ");
            self.btnLgbtq.alpha = 1;
            self.lblLgbtq.alpha = 1;
        } else {
            self.imgLgbtq.image = UIImage(named: "LGBTQ_gray");
            self.btnLgbtq.alpha = 0.5;
            self.lblLgbtq.alpha = 0.5;
        }
    }
    
    @IBAction func onBtnSignup(_ sender: Any) {
        if (edtFirstName.text == "") {
            showMessage(title: "Require", content: "Input firstname, first.") {
                self.edtFirstName.becomeFirstResponder();
            }
            return;
        }
        if (edtBirthday.text == "") {
            showMessage(title: "Require", content: "Select Birthday, first.") {
                self.view.endEditing(true)
                self.showDatePickerBox(isShow: true);
            }
            return;
        }
        if (genderOption == nil) {
            showMessage(title: "Require", content: "Select Gender, first.")
            return;
        }
        
        var data = Dictionary<String, Any>();
        
        data ["phoneNumber"] = phoneNumber;
        data ["firstName"] = edtFirstName.text;
        data ["birthday"] = edtBirthday.text;
        data ["gender"] = genderOption! ? 1 : 0;
        data ["lgbtq"] = isCheckLgbtq ? 1 : 0;
        
        if (instagramUser != nil) {
            data ["instagramName"] = instagramUser?.fullName;
            data ["photoUrl"] = instagramUser?.profilePicture.absoluteString;
        } else {
            data ["instagramName"] = "";
            data ["photoUrl"] = "";
        }
        
        let result = Extern.transMng.register(regData: data);
        if (result) {
            btnSignup.isEnabled = false;
        } else {
            showNetworkErrorMessage();
        }
    }
    
    func onRegister(result: Bool, message: String?) {
        if (result) {
            UserDefaults.standard.set(true, forKey: UserKey.IsSignup);
            UserDefaults.standard.set(nil, forKey: UserKey.IsAllowDevice);
            UserDefaults.standard.set(phoneNumber, forKey: UserKey.PhoneNumber);
            
            _ = Extern.transMng.login(phoneNumber: phoneNumber, photoUrl: instagramUser?.profilePicture);
        } else {
            showMessage(title: "Registration error", content: message!);
        }
    }
    
    func onLogin(result: Int, message: String?) {
        if (result > 0) {
            let uploadVC: UploadVideoViewController = self.storyboard?.instantiateViewController(withIdentifier: "UploadVideoViewController") as! UploadVideoViewController;
            
            self.navigationController?.setNavigationBarHidden(true, animated: true);
            self.navigationController?.pushViewController(uploadVC, animated: true);
        } else {
            showMessage(title: "Login error", content: message!);
        }
    }
}

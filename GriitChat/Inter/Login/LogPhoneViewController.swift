//
//  LogPhoneViewController.swift
//  GriitChat
//
//  Created by leo on 13/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit

class LogPhoneViewController: UIViewController, CountryListDelegate, TransMngLoginDelegate {

    
    @IBOutlet weak var btnLearnFacebook: UIButton!
    
    @IBOutlet weak var imgFlag: UIImageView!
    
    @IBOutlet weak var btnShowCountry: UIButton!
    
    @IBOutlet weak var lblCntCode: UILabel!
    
    @IBOutlet weak var edtPhoneNumber: UITextField!
    
    @IBOutlet weak var btnNext: UIButton!
    
    var countryList: CountryList? = nil;
    var currentCountry: Country? = nil;
    
    var phoneNumber: String? = nil;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Navigation Bar
        self.title = "Login griit"
        
        let backView: GradientView = super.view as! GradientView;
        backView.setBackColors(colors: [UIColor.dodgerBlue.cgColor, UIColor.brightLightBlue.cgColor]);
        
        self.navigationController?.navigationBar.isHidden = false;
        
        navigationController?.navigationBar.backgroundColor = UIColor.clear
        navigationController?.navigationBar.barTintColor = UIColor.dodgerBlue;
        
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        
        btnShowCountry.layer.cornerRadius = 5;
        btnShowCountry.clipsToBounds = true;
        //edtPhoneNumber
        
        btnShowCountry.titleEdgeInsets = UIEdgeInsetsMake(10, 0, 10, 0);
        btnShowCountry.backgroundColor = UIColor.darkSkyBlue
        edtPhoneNumber.backgroundColor = UIColor.darkSkyBlue
        
        //Learn Facebook Button
        let attrs: [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.underlineStyle : 1,
            NSAttributedStringKey.foregroundColor: UIColor.white]
        
        let attributedString = NSAttributedString.init(string: "Learn how Facebook uses your info.", attributes: attrs)
        
//        let buttonTitleStr = NSMutableAttributedString(string:"My Button", attributes:attrs)
        
        btnLearnFacebook.setAttributedTitle(attributedString, for: .normal)
        
        //Next Button
        btnNext.layer.cornerRadius = btnNext.frame.height / 2;
        btnNext.clipsToBounds = true;
        btnNext.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        
        currentCountry = Country(countryCode: "US", phoneExtension: "1")
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        view.addGestureRecognizer(tap);
        
        Extern.transMng.loginDelegate = self;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        Extern.transMng.loginDelegate = self;
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func onChangePhoneNumber(_ sender: Any) {
        let length: Int = edtPhoneNumber.text?.count as! Int;
        let Max: Int = Int(10);
        if (length > Max) {
            let text: String = edtPhoneNumber.text!;
            let indexStartOfText: String.Index = text.index(text.startIndex, offsetBy: Max)
        
            edtPhoneNumber.text = String(text[..<indexStartOfText]);
        }
    }
    /*
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if (identifier == "nextPhoneNumber") {
            if (edtPhoneNumber.text?.count != 10) {
                return false;
            }
        }
        return true;
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let phoneNumber: String = edtPhoneNumber.text!;
        let destVC: LoginCodeViewController = segue.destination as! LoginCodeViewController;
        
        destVC.phoneNumber = "+" + (currentCountry?.phoneExtension)! + phoneNumber;
        destVC.countryCode = (currentCountry?.countryCode)!;
    }*/
    
    @IBAction func onBtnCountry(_ sender: Any) {
        countryList = CountryList()
        countryList?.delegate = self
        self.navigationController?.pushViewController(countryList!, animated: true);
        
//        let navController = UINavigationController(rootViewController: countryList)
//        self.present(navController, animated: true, completion: nil)
    }
    
    func selectedCountry(country: Country) {
//        textView.textContainerInset = UIEdgeInsetsMake(10, 0, 10, 0)
        btnShowCountry.setTitle(country.flag! + "+" + country.phoneExtension, for: .normal)
        currentCountry = country;
    }
    
    @IBAction func onBtnNext(_ sender: Any) {
        if (edtPhoneNumber.text?.count != 10) {
            showMessage(title: "Type Error", content: "Input Phonenumber as 10 digits.", completion: nil);
            return;
        }
        
        phoneNumber = (currentCountry?.phoneExtension)! + edtPhoneNumber.text!;
        
        let result = Extern.transMng.sendMessage(msg: ["id": "generateCodeWithPhoneNumber",
                                                       "phoneNumber": phoneNumber]);
        
        if (!result) {
            showNetworkErrorMessage();
        } else {
            btnNext.isEnabled = false;
            btnShowCountry.isEnabled = false;
            InstagramManager.shared.token = nil;
        }
    }
    
    func onGenerateCodeWithPhoneNumberResponse(message: Dictionary<String, Any>) {
        let result = message ["result"] as! Int;
        if (result == -1) {
            showMessage(title: "Error", content: message ["message"] as! String);
            self.btnNext.isEnabled = true;
            self.btnShowCountry.isEnabled = true;
            return;
        }
        
        let smsCode = message ["code"] as! Int;
        
        let checkCodeVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginCodeViewController") as! LoginCodeViewController;
        checkCodeVC.phoneNumber = phoneNumber!;
        checkCodeVC.afterCheck = result;
        
        var strSms = String(format: "%d", smsCode);
        for index in 0 ..< 6 - strSms.count {
            strSms = "0" + strSms;
        }
        checkCodeVC.strCode = strSms;
        
        showMessage(title: "SMS arrived.", content: strSms, completion: {
            self.navigationController?.pushViewController(checkCodeVC, animated: true);
            
            self.btnNext.isEnabled = true;
            self.btnShowCountry.isEnabled = true;
        });
    }
}

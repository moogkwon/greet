//
//  ViewController.swift
//  GriitChat
//
//  Created by leo on 03/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit

class ViewController: UIViewController, TransMngLoginDelegate, TransMngUserInfoDelegate, TransMngInCallDelegate {
    func onChangeIncomingList() {
        
    }
    
    func onRecvVideoProfileResult(result: Bool, message: String?) {
        
    }
    
    func onRecvBinary(data: Data) {
        
    }
    
    
    
    let SVR_URL = "wss://192.168.42.1:8443/center";
    let KMS_URL = "ws://192.168.42.134:8888/kurento";
    
    var transMng: TransMng?;
    
    @IBOutlet weak var edtUsername: UITextField!
    
    @IBOutlet weak var edtCallUsername: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.transMng = TransMng(svrUrl: SVR_URL, kmsUrl: KMS_URL);
        self.transMng?.loginDelegate = self;
        self.transMng?.incomingCallDelegate = self;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onBtnConnect(_ sender: Any) {
        self.transMng?.connect();
    }
    
    @IBAction func onBtnRegister(_ sender: Any) {
        var regData: Dictionary<String, Any> = Dictionary<String, Any>();
        //message: {phoneNumber, firstName, birthday, gender, location, photo, video}
        regData ["phoneNumber"] = "+14323346543";
        regData ["firstName"] = "testName";
        regData ["birthday"] = "2018-05-05";
        regData ["gender"] = 3;
        regData ["location"] = "Losangles, United State";
        regData ["location_lat"] = "";
        regData ["location_lng"] = "";
        regData ["photo"] = defaultPhoto;
        regData ["video"] = "";
        
        _ = self.transMng?.register(regData: regData);
    }
    
    @IBAction func onBtnLogin(_ sender: Any) {
//        _ = self.transMng?.login(phoneNumber: self.edtUsername.text!, photoPath: nil);
    }
    
    
    @IBAction func onBtnLogout(_ sender: Any) {
        self.transMng?.logout();
    }
    
    @IBAction func onGetUserInfo(_ sender: Any) {
        self.transMng?.userInfoDelegate = self;
//        self.transMng?.getUserInfos(mode: TransMng.GetUserMode.Random);
    }
    
    
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if (identifier == "segueCall") {
            let userName = edtCallUsername.text;
            var msg: String = "";
            if (self.transMng?.isLogined() == false) {
                msg = "Please login before call.";
            } else if (userName == "") {
                msg = "Input callee name.";
            } else {
                return true;
            }
            
            let alert = UIAlertController(title: "Error", message: msg, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil);
            
            return false;
        }
        return true;
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "segueCall") {
            let callVC = segue.destination as! CallingViewController;
            callVC.calleePhoneNumber = edtCallUsername.text;
            callVC.transMng = self.transMng;
            callVC.modalPresentationStyle = UIModalPresentationStyle.overFullScreen;
        }
    }
    
    
    //TransMngLoginDelegate
    func onConnect(result: Bool) {
        var msg: String;
        if (result) {
            msg = "Connected Successfully.";
        } else {
            msg = "Connected failed.";
        }
        let alert = UIAlertController(title: "Connect Result", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func onRegister(result: Bool, message: String?) {
        let alert = UIAlertController(title: "Register Result", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func onLogin(result: Bool, message: String?) {
        var msg: String;
        if (result) {
            msg = "Logined Successfully.";
        } else {
            msg = message!;
        }
        let alert = UIAlertController(title: "Login Result", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func onLogout(message: String?) {
        let alert = UIAlertController(title: "Logout Result", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    //---//TransMngLoginDelegate
    
    //TransMngUserInfoDelegate
    func onUserInfoReceived(data: Dictionary<String, Any>) {
        debugPrint(data);
    }
    //---//TransMngUserInfoDelegate
    
    
    @IBOutlet weak var btnIncomeCall: UIButton!
    
    var incomingSndList: [String: Int] = [String: Int]();
    //TransMngIncallDelegate
    //data: {caller, [photo]}
    func onIncomingCalling(data: Dictionary<String, Any>) {
        let caller: String = (data ["caller"] as? String)!;
        btnIncomeCall.setTitle(caller, for: UIControlState.normal);
        btnIncomeCall.isEnabled = true;
        
        let userInfo = [
            "caller": caller
            ] as [String : Any];
        incomingSndList [caller] = TransMng.COUNT_RINGTONE;
        
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(ViewController.updateTimer)), userInfo: userInfo, repeats: true);
        
        self.transMng?.sendRingtone(result: 0, caller: caller, remainSec: TransMng.COUNT_RINGTONE);
        
        lblCallerSecond.text = String(incomingSndList [caller]!);
    }
    
    func onIncomingCall(message: Dictionary<String, Any>) {
        let chatVC = self.storyboard?.instantiateViewController(withIdentifier: "EngineChatViewController") as! EngineChatViewController;
        chatVC.transMng = self.transMng;
        
        chatVC.fromId = message ["from"] as! String;
//        chatVC.toId = (self.transMng?.phoneNumber)!;
        chatVC.userType = EngineChatViewController.UserType.Callee;
        self.navigationController?.pushViewController(chatVC, animated: true);
    }
    
    func stopCalling(message: Dictionary<String, Any>) {
        let phoneNumber: String = message ["phoneNumber"] as! String;
        
        if (incomingSndList [phoneNumber] == nil) {
            return;
        }
        incomingSndList.removeValue(forKey: phoneNumber);
    }
    //---//TransMngIncallDelegate
    
    
    
    @objc func updateTimer(timer: Timer) {
        let userInfo = timer.userInfo as! [String : Any];
        let caller = userInfo ["caller"] as! String;
        
        if (incomingSndList [caller] == nil) {
            timer.invalidate();
            return;
        }
        
        if (incomingSndList [caller] == 0) {
            //Ends up incoming call
            incomingSndList.removeValue(forKey: caller);
            timer.invalidate();
            btnIncomeCall.setTitle("No Caller", for: UIControlState.normal);
            
            btnIncomeCall.isEnabled = false;
            return;
        } else {
            //Send Ringtone to caller.
            incomingSndList [caller] = incomingSndList [caller]! - 1;
            
            self.transMng?.sendRingtone(result: 0, caller: caller, remainSec: incomingSndList [caller]!);
            
            btnIncomeCall.setTitle(caller + String(describing: incomingSndList [caller]), for: UIControlState.normal);
            
            lblCallerSecond.text = String(incomingSndList [caller]!);
            
            debugPrint(incomingSndList [caller]!);
        }
    }
    
    
    @IBOutlet weak var lblCallerSecond: UILabel!
    
    @IBAction func onReceiveIncomingCall(_ sender: Any) {
        let caller: String = Array(incomingSndList.keys)[0];
        incomingSndList [caller] = 0;
        
        self.transMng?.sendRingtone(result: 1, caller: caller, remainSec: 0);
        
        btnIncomeCall.setTitle("Waiting... (" + caller + ")", for: .normal);
        btnIncomeCall.isEnabled = false;
        self.transMng?.userStatus = .WaitingCall;
    }
    /*
    func onCreatePeer(caller: String) {
        let chatVC = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController;
        
        chatVC.transMng = self.transMng;
        chatVC.phoneNumber = caller;
        chatVC.userType = ChatViewController.UserType.Callee;
        self.navigationController?.pushViewController(chatVC, animated: true);
    }*/
    
    
    let defaultPhoto = "";
}


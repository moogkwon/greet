//
//  CallingViewController.swift
//  GriitChat
//
//  Created by leo on 05/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit

class CallingViewController: UIViewController, TransMngCallingDelegate {
    
    var calleePhoneNumber: String?;
    var transMng: TransMng?;
    
    @IBOutlet weak var lblRemainSec: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startCall();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startCall() {
        if (transMng?.isLogined() == false) {
            self.navigationController?.popViewController(animated: true);
            return;
        }
        transMng?.callingDelegate = self;
        _ = transMng?.call(phoneNumber: calleePhoneNumber!);
    }
    /*{
         result: message.result,
         callee: callee.phoneNumber,
         remainSec: message.remainSec
         }
     */
    func onCallingResponse(data: Dictionary<String, Any>) {
        if (data ["callee"] == nil) {
            self.navigationController?.popViewController(animated: true);
            
            let alert = UIAlertController(title: "Calling Result", message: data ["message"] as! String, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return;
        }
        let result: Int = data ["result"] as! Int;
        let callee: String = data ["callee"] as! String;
        let remainSec: Int = data ["remainSec"] as! Int;
        
        if (callee != calleePhoneNumber) {
            return;
        }
        
        if (result == -1) {
            self.navigationController?.popViewController(animated: true);
            transMng?.userStatus = .Logined;
        } else if (result == 0) {
            if (remainSec == 0) {
                self.navigationController?.popViewController(animated: true);
                transMng?.userStatus = .Logined;
            } else {
                debugPrint(remainSec);
                DispatchQueue.main.async {
                    self.lblRemainSec.text = String(remainSec);
                    debugPrint("Async");
                    debugPrint(self.lblRemainSec.text);
                }
                debugPrint(self.lblRemainSec.text);
            }
        } else if (result == 1) {
            let chatVC = self.storyboard?.instantiateViewController(withIdentifier: "EngineChatViewController") as! EngineChatViewController;
            transMng?.userStatus = .ReadyCall;
            chatVC.transMng = self.transMng;
            chatVC.toId = callee;
//            chatVC.fromId = (self.transMng?.phoneNumber)!;
            chatVC.userType = EngineChatViewController.UserType.Caller;
            
            var VCs = self.navigationController?.viewControllers;
            VCs! [((VCs?.count)! - 1)] = chatVC;
            self.navigationController?.setViewControllers(VCs!, animated: true);
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        transMng?.stopCalling(phoneNumber: calleePhoneNumber!);
    }
    

}

//
//  CalleeViewController.swift
//  GriitChat
//
//  Created by leo on 17/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit
/*
protocol CalleeReceiveCallDelegate {
    func onCalleeIncomingCall(message: Dictionary<String, Any>);
};*/

class CalleeViewController: UIViewController, TransMngLoginDelegate,TransMngInCallDelegate, IncallViewDelegate {

//    var sToolbarView: ToolbarView!
    
    var sIncallingStack: UIStackView!
    
    var incomingList: [String: IncallView] = [String: IncallView]();
    
    var sBtnCup: UIButton!;
    
    var currentController = "";
    
//    var incomingCallDelegate: CalleeReceiveCallDelegate?;

    override func viewDidLoad() {
        super.viewDidLoad()
        
        createStackView();
//        createToolbarView();
        createBtnCup();
        
        Extern.transMng.incomingCallDelegate = self;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        
        sIncallingStack.addArrangedSubview(UIView(frame: sIncallingStack.bounds));
        onChangeIncomingList();
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func setGradientBack(view: UIView) {
        let backView: GradientView = view as! GradientView;
        backView.setBackColors(colors: [UIColor.dodgerBlue.cgColor, UIColor.brightLightBlue.cgColor]);
    }
    
    func createStackView() {
        sIncallingStack = UIStackView(frame: view.bounds);
        sIncallingStack.translatesAutoresizingMaskIntoConstraints = false;
        sIncallingStack.axis = .vertical;
        sIncallingStack.alignment = .leading;
        sIncallingStack.spacing = 10;
        
        view.addSubview(sIncallingStack);
        
        let horzCont = NSLayoutConstraint(item: sIncallingStack, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 0.25, constant: 0);
        let vertCont = NSLayoutConstraint(item: sIncallingStack, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0);
        let widthCont = NSLayoutConstraint(item: sIncallingStack, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 0.13, constant: 0);
        let heightCont = NSLayoutConstraint(item: sIncallingStack, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 0.3, constant: 0);
        view.addConstraints([horzCont, vertCont, widthCont, heightCont]);
    }
    
    /*func createToolbarView() {
        sToolbarView = ToolbarView(frame: view.bounds);
        sToolbarView.translatesAutoresizingMaskIntoConstraints = false;
        view.addSubview(sToolbarView);
        
        let horzCont = NSLayoutConstraint(item: sToolbarView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0);
        let bottomCont = NSLayoutConstraint(item: sToolbarView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0);
        
        let widthCont = NSLayoutConstraint(item: sToolbarView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0);
        let heightCont = NSLayoutConstraint(item: sToolbarView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 0.06, constant: 0);
        
        
        view.addConstraints([horzCont, bottomCont, widthCont, heightCont]);
        
        sToolbarView.isTransparent = true;
        sToolbarView.parent = self;
        sToolbarView.backgroundColor = nil;
    }*/
    
    func createBtnCup() {
        sBtnCup = UIButton(frame: view.bounds);
        
        sBtnCup.translatesAutoresizingMaskIntoConstraints = false;
        
        view.addSubview(sBtnCup);
        
        let horzCont = NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: sBtnCup, attribute: .trailing, multiplier: 1, constant: 30);
        let vertCont = NSLayoutConstraint(item: sBtnCup, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 0.2, constant: 0);
        let widthCont = NSLayoutConstraint(item: sBtnCup, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 0.065, constant: 0);
        let heightCont = NSLayoutConstraint(item: sBtnCup, attribute: .width, relatedBy: .equal, toItem: sBtnCup, attribute: .height, multiplier: 0.86, constant: 0);
        view.addConstraints([horzCont, vertCont, widthCont, heightCont]);
        
        sBtnCup.setTitle("", for: .normal)
        sBtnCup.setImage(UIImage(named: "cup"), for: .normal);
        
        sBtnCup.addTarget(self, action: #selector(onBtnCup), for: .touchUpInside)
    }
    
    @objc func onBtnCup(sender: UIButton!) {
//        let cupView = CupFullView.createView(controller: self);
//        cupView.showPresent();
        
        let cupView = CupHalf.createView(controller: self);
        cupView.showPresent();
    }

    
    func onChangeIncomingList() {
        for phoneNumber in self.incomingList.keys {
            if (Extern.transMng.incomingList [phoneNumber] == nil) {
                self.incomingList [phoneNumber]?.removeFromSuperview();
                self.incomingList.removeValue(forKey: phoneNumber);
                self.incomingList [phoneNumber] = nil;
            }
        }
        for phoneNumber in Extern.transMng.incomingList.keys {
            if (self.incomingList [phoneNumber] == nil) {
                self.incomingList [phoneNumber] = self.addCallerView(phoneNumber: phoneNumber, image: (Extern.transMng.incomingList [phoneNumber]?.imgPhoto)!);
            }
            
            self.incomingList [phoneNumber]?.setProg(curVal: (Extern.transMng.incomingList [phoneNumber]?.remainSec)!, maxVal: TransMng.COUNT_RINGTONE);
        }
    }
    
    func onIncomingCall(message: Dictionary<String, Any>) {
        debugPrint("Receive call!!!");
        fatalError("This function have to be override.");
//        incomingCallDelegate?.onIncomingCall(message: message);
        /*let chatVC = self.storyboard?.instantiateViewController(withIdentifier: "EngineChatViewController") as! EngineChatViewController;
         chatVC.transMng = self.transMng;
         
         chatVC.fromId = message ["from"] as! String;
         chatVC.toId = (self.transMng?.phoneNumber)!;
         chatVC.userType = EngineChatViewController.UserType.Callee;
         self.navigationController?.pushViewController(chatVC, animated: true);*/
    }
    
    func onReceiveCall(phoneNumber: String) {
        Extern.transMng.resetState();
        
        Extern.transMng.receiveCall(phoneNumber: phoneNumber);
    }
    
    func addCallerView(phoneNumber: String, image: UIImage) -> IncallView {
        let width: CGFloat = sIncallingStack.bounds.width;
        
        let incallView: IncallView = IncallView(frame: CGRect(x: 0, y: 0, width: width, height: width));
        
        incallView.setImage(image: image);
        incallView.layer.cornerRadius = sIncallingStack.bounds.width / 2;
        incallView.clipsToBounds = true;
        
        let heightConstraint = NSLayoutConstraint(item: incallView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: width);
        
        NSLayoutConstraint.activate([heightConstraint]);
        
        sIncallingStack.addArrangedSubview(incallView);
        sIncallingStack.translatesAutoresizingMaskIntoConstraints = false;
        
        incallView.layout(width: width);
        incallView.phoneNumber = phoneNumber;
        incallView.delegate = self;
        
        return incallView;
    }
    
    func onConnect(result: Bool) {
        if (!result) {
            showMessage(title: "Network Error", content: "Network connection closed.");
        }
    }
}

//
//  CalleeViewController.swift
//  GriitChat
//
//  Created by leo on 17/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit

class CalleeViewer: UIView, TransMngLoginDelegate,TransMngInCallDelegate, IncallViewDelegate {
    
    var sIncallingStack: UIStackView!
    
    var incomingList: [String: IncallView] = [String: IncallView]();
    
    var sBtnCup: UIButton!;
    
    var currentController = "";

    override init(frame: CGRect) {
        super.init(frame: frame);
        commonInit();
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        commonInit();
    }
    
    func commonInit() {
        createStackView();
        createBtnCup();
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        
        sIncallingStack.addArrangedSubview(UIView(frame: sIncallingStack.bounds));
    }
    
    func initState() {
        Extern.transMng.incomingCallDelegate = self;
        onChangeIncomingList();
    }
    
    func setGradientBack(view: UIView) {
        let backView: GradientView = view as! GradientView;
        backView.setBackColors(colors: [UIColor.dodgerBlue.cgColor, UIColor.brightLightBlue.cgColor]);
    }
    
    func createStackView() {
        sIncallingStack = UIStackView(frame: bounds);
        sIncallingStack.translatesAutoresizingMaskIntoConstraints = false;
        sIncallingStack.axis = .vertical;
        sIncallingStack.alignment = .leading;
        sIncallingStack.spacing = 10;
        
        addSubview(sIncallingStack);
        
        let horzCont = NSLayoutConstraint(item: sIncallingStack, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 0.25, constant: 0);
        let vertCont = NSLayoutConstraint(item: sIncallingStack, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0);
        let widthCont = NSLayoutConstraint(item: sIncallingStack, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.13, constant: 0);
        let heightCont = NSLayoutConstraint(item: sIncallingStack, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0.3, constant: 0);
        addConstraints([horzCont, vertCont, widthCont, heightCont]);
    }
    
    func createBtnCup() {
        sBtnCup = UIButton(frame: bounds);
        
        sBtnCup.translatesAutoresizingMaskIntoConstraints = false;
        
        addSubview(sBtnCup);
        
        let horzCont = NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: sBtnCup, attribute: .trailing, multiplier: 1, constant: 30);
        let vertCont = NSLayoutConstraint(item: sBtnCup, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 0.2, constant: 0);
        let widthCont = NSLayoutConstraint(item: sBtnCup, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.065, constant: 0);
        let heightCont = NSLayoutConstraint(item: sBtnCup, attribute: .width, relatedBy: .equal, toItem: sBtnCup, attribute: .height, multiplier: 0.86, constant: 0);
        self.addConstraints([horzCont, vertCont, widthCont, heightCont]);
        
        sBtnCup.setTitle("", for: .normal)
        sBtnCup.setImage(UIImage(named: "cup"), for: .normal);
        
        sBtnCup.addTarget(self, action: #selector(onBtnCup), for: .touchUpInside)
    }
    
    @objc func onBtnCup(sender: UIButton!) {
//        let cupView = CupFullView.createView(controller: self);
//        cupView.showPresent();
        
//        let cupView = CupHalf.createView(controller: self);
//        cupView.showPresent();
    }

    func removeAllList() {
        for phoneNumber in self.incomingList.keys {
            if (Extern.transMng.incomingList [phoneNumber] == nil) {
                self.incomingList [phoneNumber]?.removeFromSuperview();
                self.incomingList.removeValue(forKey: phoneNumber);
                self.incomingList [phoneNumber] = nil;
            }
        }
    }
    
    func onChangeIncomingList() {
        removeAllList();
        for phoneNumber in Extern.transMng.incomingList.keys {
            if (self.incomingList [phoneNumber] == nil) {
                self.incomingList [phoneNumber] = self.addCallerView(phoneNumber: phoneNumber, photoUrl: (Extern.transMng.incomingList [phoneNumber]?.photoUrl)!);
            }
            
            self.incomingList [phoneNumber]?.setProg(curVal: (Extern.transMng.incomingList [phoneNumber]?.remainSec)!, maxVal: TransMng.COUNT_RINGTONE);
        }
    }
    
    var clsName = "";
    func onIncomingCall(message: Dictionary<String, Any>) {
        debugPrint("Receive call!!!");
        debugPrint("Class Name: ", clsName);
        fatalError("This function have to be override.");
    }
    
    func onReceiveCall(phoneNumber: String) {
        Extern.transMng.resetState();
        
        Extern.transMng.receiveCall(phoneNumber: phoneNumber);
    }
    
    func addCallerView(phoneNumber: String, photoUrl: String) -> IncallView {
        let width: CGFloat = sIncallingStack.bounds.width;
        
        let incallView: IncallView = IncallView(frame: CGRect(x: 0, y: 0, width: width, height: width));
        
        incallView.setImage(url: photoUrl);
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
        debugPrint("On Connect: ", clsName);
        if (!result) {
            Extern.mainVC?.showMessage(title: "Network Error", content: "Network connection closed.", completion: nil);
        }
    }
}

//
//  CalleeViewController.swift
//  GriitChat
//
//  Created by leo on 17/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit
import UserNotifications
/*
protocol CalleeReceiveCallDelegate {
    func onCalleeIncomingCall(message: Dictionary<String, Any>);
};*/

class CalleeViewController: UploadVideoTemplateViewController, TransMngLoginDelegate,TransMngInCallDelegate, IncallViewDelegate, CupManagerDelegate {

//    var sToolbarView: ToolbarView!
    
    var incomingList: IncomingList? = nil;
    
    var sBtnCup: UIButton!;
    
//    var incomingCallDelegate: CalleeReceiveCallDelegate?;
    
    var _cupPurchaseView: CupFullView? = nil;
    var cupPurchaseView: CupFullView {
        set { _cupPurchaseView = newValue }
        get {
            if (_cupPurchaseView == nil) {
                _cupPurchaseView = CupFullView.createView(controller: self);
            }
            return _cupPurchaseView!;
        }
    }
    
    var _cupFilteringView: CupHalf? = nil;
    var cupFilteringView: CupHalf {
        set { _cupFilteringView = newValue }
        get {
            if (_cupFilteringView == nil) {
                _cupFilteringView = CupHalf.createView(controller: self);
            }
            return _cupFilteringView!;
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        createToolbarView();
    }
    
    func onInit() {
        Extern.transMng.incomingCallDelegate = self;
        Extern.transMng.loginDelegate = self;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        
        onChangeIncomingList();
    }
    
    func setGradientBack(view: UIView) {
        let backView: GradientView = view as! GradientView;
        backView.setBackColors(colors: [UIColor.dodgerBlue.cgColor, UIColor.brightLightBlue.cgColor]);
    }
    
    func createIncomingList() {
        if (incomingList != nil) { return }
        
        let incomingListFrame = IncomingList.getEstimateRect(frame: self.view.frame);
        incomingList = IncomingList(frame: incomingListFrame);
        self.view.addSubview(incomingList!);
        incomingList?.commonInit();
    }
    
    func createBtnCup() {
        if (sBtnCup != nil) { return }

        sBtnCup = UIButton(frame: view.bounds);
        view.addSubview(sBtnCup);
        
        sBtnCup.translatesAutoresizingMaskIntoConstraints = false;
        
        
        let horzCont = NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: sBtnCup, attribute: .trailing, multiplier: 1, constant: 20);
        let vertCont = NSLayoutConstraint(item: sBtnCup, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 0.2, constant: 0);
        let widthCont = NSLayoutConstraint(item: sBtnCup, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 0.1, constant: 0);
        let heightCont = NSLayoutConstraint(item: sBtnCup, attribute: .width, relatedBy: .equal, toItem: sBtnCup, attribute: .height, multiplier: 0.86, constant: 0);
        view.addConstraints([horzCont, vertCont, widthCont, heightCont]);
        
        sBtnCup.setTitle("", for: .normal)
        sBtnCup.setImage(UIImage(named: "cup"), for: .normal);
        sBtnCup.contentEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
        
        sBtnCup.addTarget(self, action: #selector(onBtnCup), for: .touchUpInside)
    }
    
    func onChangeIncomingList() {
        //Remove
        DispatchQueue.main.async {
            for phoneNumber in (self.incomingList?.viewList.keys)! {
                if (Extern.transMng.incomingList [phoneNumber] == nil) {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.incomingList?.viewList [phoneNumber]?.alpha = 0;
                    }, completion: { (result: Bool) in
                        self.incomingList?.viewList [phoneNumber]?.removeFromSuperview();
                        self.incomingList?.viewList.removeValue(forKey: phoneNumber);
                        self.incomingList?.viewList [phoneNumber] = nil;
                    })
                }
            }
            for phoneNumber in Extern.transMng.incomingList.keys {
                if (self.incomingList?.viewList [phoneNumber] == nil) {
                    let incallView = self.addCallerView(phoneNumber: phoneNumber, photoUrl: (Extern.transMng.incomingList [phoneNumber]?.photoUrl)!);
                    
                    _ = self.incomingList?.addView(phoneNumber: phoneNumber, view: incallView);
                    
                    self.showNotification(strTitle: "Incoming call...", strContent: phoneNumber + " is calling you...");
                    self.registerNotificationAction();
                }
                
                self.incomingList?.viewList [phoneNumber]?.setProg(curVal: (Extern.transMng.incomingList [phoneNumber]?.remainSec)!, maxVal: TransMng.COUNT_RINGTONE);
            }
            self.incomingList?.layoutSubviews();
        }
    }
    
    func onIncomingCall(message: Dictionary<String, Any>) {
        debugPrint("Receive call!!!");
        fatalError("This function have to be override.");
    }
    
    //Called when user touch incoming item.
    func onReceiveCall(phoneNumber: String) {
        Extern.transMng.resetState();
        Extern.mainVC?.onPause();
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            Extern.transMng.receiveCall(phoneNumber: phoneNumber);
            Extern.mainVC?.sToolbarView.slideToolbar(ratio: 1, direction: .Down);
            Extern.mainVC?.chattingPage.isReceivedIncomingCall = true;
        }
    }
    
    func addCallerView(phoneNumber: String, photoUrl: String) -> IncallView {
        let width: CGFloat = (incomingList?.bounds.width)!;
        
        let incallView: IncallView = IncallView(frame: CGRect(x: 0, y: 0, width: width, height: width));
        
        incallView.setImage(url: photoUrl);
        incallView.layer.cornerRadius = (incomingList?.bounds.width)! / 2;
        incallView.clipsToBounds = true;
        
        incallView.layout(width: width);
        incallView.phoneNumber = phoneNumber;
        incallView.delegate = self;
        
        return incallView;
    }
    
    func onConnect(result: Bool) {
        if (!result) {
            showMessage(title: "Network Error", content: "Network connection closed.") {
//                Extern.mainVC?.dismiss(animated: true, completion: nil);
                self.navigationController?.popToRootViewController(animated: true);
            }
        }
    }
    
    
    func showNotification(strTitle: String, strContent: String) {
        // Create a content
        let content = UNMutableNotificationContent.init()
        content.title = NSString.localizedUserNotificationString(forKey: strTitle, arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: strContent, arguments: nil)
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "categoryIdentifier"
        
        // Create a unique identifier for each notification
        let identifier = UUID.init().uuidString
        
        // Notification trigger
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 5, repeats: false)
        
        // Notification request
        let request = UNNotificationRequest.init(identifier: identifier, content: content, trigger: trigger)
        
        // Add request
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
    }
    
    func registerNotificationAction() {
        let first = UNNotificationAction.init(identifier: "first", title: "Go", options: [])
        let category = UNNotificationCategory.init(identifier: "categoryIdentifier", actions: [first], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if response.notification.request.content.categoryIdentifier == "categoryIdentifier" {
            
            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                print(response.actionIdentifier)
                completionHandler()
            case "first":
                print(response.actionIdentifier)
                completionHandler()
            default:
                break;
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        //2
        completionHandler([.alert, .sound])
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////
    /////////////////////////               CUP
    /////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    @objc func onBtnCup(sender: UIButton!) {
        showCupPage();
    }
    
    func showCupPage(_ completion: (() -> Void)? = nil) {
        if (Extern.cupManager.getCupCount() == 0 && !Extern.cupManager.isUsingCup()) {
            showPurchasePage(isShowFilter: true);
            return;
        }
        
        cupFilteringView.showPresent(completion);
    }
    
    func showPurchasePage(isShowFilter: Bool) {
        cupPurchaseView.showPresent(isShowFilter: isShowFilter);
    }
    
    
    func onCupCountChanged(cupCount: Int) {
        DispatchQueue.main.async {
            self.cupPurchaseView.lblRemainCupCount.text = String(format: "%d", cupCount);
            self.cupFilteringView.lblCupCount.text = String(format: "%d", cupCount);
            self.cupPurchaseView.btnCenterLogo.isSelected = cupCount != 0;
        }
    }
    
    func onCupDurationChanged(duration: Double) {
        self.cupFilteringView.refreshView();
    }
    
    func onCupStateChanged(isUse: Bool) {
        sBtnCup.imageView?.image = nil;
        if (isUse) {
            sBtnCup.setImage(UIImage(named: "cup"), for: .normal);
        } else {
            sBtnCup.setImage(UIImage(named: "cup_empty"), for: .normal);
        }
        self.cupFilteringView.refreshView();
    }
}

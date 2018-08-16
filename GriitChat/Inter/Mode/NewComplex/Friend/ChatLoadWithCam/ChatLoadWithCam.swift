//
//  ChatLoadWithCam.swift
//  GriitChat
//
//  Created by leo on 27/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit

//Call(phoneNumber) =>  GetUserInfo =>  Call    => callingdelegate => ..... process...

class ChatLoadWithCam: ViewPage, TransMngCallingDelegate {

    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var camView: CameraView!
    
    @IBOutlet weak var loadingView: LoadingView!
    
    var phoneNumber: String? = nil;
    var userInfo: Dictionary<String, Any>? = nil;
    var callingRemainSec = -1;
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        commonInit();
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        commonInit();
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("ChatLoadWithCam", owner: self, options: nil);
        addSubview(contentView);
        contentView.frame = self.bounds;
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight];
    }
    
    override func initState() {
        super.initState()
        
        loadingView.setGradBackAlpha(alpha: 0.3);
        loadingView.setProgMaxValue(maxValue: CGFloat(TransMng.COUNT_RINGTONE - 1));
        loadingView.showLabel(number: TransMng.COUNT_RINGTONE);
    }
    
    override func onActive() {
        if (isActive) { return }
        
        super.onActive();
        Extern.transMng.resetState();
        Extern.transMng.callingDelegate = self;
        
        _ = camView.setupAVCapture();
        
        Extern.transMng.sendMessage(msg: ["id": "getUserInfoWithPhoneNumber",
                                          "phoneNumber": phoneNumber]);
        
        DispatchQueue.main.async {
            Extern.mainVC?.sToolbarView.slideToolbar(ratio: 1, direction: .Down);
        }
    }
    
    override func onDeactive() {
        if (!isActive) { return }
        super.onDeactive();
        
        camView.stopCamera();
        phoneNumber = nil;
        userInfo?.removeAll();
        userInfo = nil;
    }
    
    func onGetUserInfoWithPhoneNumber(result: Int, data: Dictionary<String, Any>) {
        if (result == 0) {
            parentVC?.showMessage(title: "User Error.", content: data ["message"] as! String, completion: {
                self.afterCompletion();
            })
        } else {
            userInfo = data;
            startCall();
            loadingView.setProgValue(value: 0, duration: 0);
        }
    }
    
    func startCall() {
        _ = Extern.transMng.call(phoneNumber: userInfo! ["phoneNumber"] as! String);
        createRingtonMark(remainSec: TransMng.COUNT_RINGTONE)
        Extern.mainVC?.chattingPage.isReceivedIncomingCall = false;
    }
    
    //Caller => Server => Caller
    func onCallingResponse(data: Dictionary<String, Any>) {
        if (data ["callee"] == nil) {
            //If error comes from server...
            let alert = UIAlertController(title: "Calling Result", message: data ["message"] as? String, preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_:UIAlertAction) -> Void in
                self.afterCompletion();
            }));
            
            callingRemainSec = -1;
            parentVC?.present(alert, animated: true, completion: nil)
            return;
        }
        let result: Int = data ["result"] as! Int;
        let callee: String = data ["callee"] as! String;        //Callee PhoneNumber
        let remainSec: Int = data ["remainSec"] as! Int;
        
        if (callee != phoneNumber) {
            return;
        }
        
        if (result == -1) {
            //Refuse call in callee.
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Calling Result", message: data ["message"] as? String, preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_:UIAlertAction) -> Void in
                    self.afterCompletion();
                }));
                
                self.parentVC?.present(alert, animated: true, completion: nil)
            }
            Extern.transMng.userStatus = .Logined;
        } else if (result == 0) {
            if (remainSec == 0) {
                //Timeout...
                DispatchQueue.main.async {
                    self.afterCompletion();
                }
                Extern.transMng.userStatus = .Logined;
            } else {
                //Showing seconds.
                DispatchQueue.main.async {
                    let showProg: CGFloat = CGFloat(TransMng.COUNT_RINGTONE - remainSec);
                    
                    self.loadingView.showLabel(number: remainSec - 1);
                    self.loadingView.setProgValue(value: showProg, duration: 1.1);
                }
            }
            createRingtonMark(remainSec: remainSec);
        } else if (result == 1) {
            Extern.transMng.userStatus = .ReadyCall;
            
            Extern.mainVC?.willStartChat(userInfo: userInfo, userType: .Caller, state: .Friend_Chat);
            callingRemainSec = -1;
        }
    }
    
    func afterCompletion() {
        let curState: MainViewPageState = MainViewPageState(rawValue: pageName)!;
        switch (curState) {
        case .Friend_Loading:
            Extern.mainVC?.gotoPage(.Friend_Main);
            break;
        /*case .Moment_Loading:
            Extern.mainVC?.gotoPage(.Moment_Main);
            break;*/
        default:
            Extern.mainVC?.gotoPage(.Selective_Loading);
            return;
        }
    }
    
    func createRingtonMark(remainSec: Int) {
        self.callingRemainSec = remainSec;
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if (remainSec  == self.callingRemainSec) {
                Extern.transMng.resetState();
                DispatchQueue.main.async {
                    self.afterCompletion();
                }
            }
        };
    }
}

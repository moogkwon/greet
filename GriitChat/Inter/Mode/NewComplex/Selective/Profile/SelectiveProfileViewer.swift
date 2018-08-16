//
//  SelectiveViewController.swift
//  GriitChat
//
//  Created by leo on 15/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit

class SelectiveProfileViewer: ViewPage, UIActionSheetDelegate, TransMngCallingDelegate {
    
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet var profileViewer: ProfileViewer!
    
    @IBOutlet weak var imgPhoto: UIImageView!
    
    @IBOutlet weak var lblUserName: UILabel!
    
    @IBOutlet weak var lblUserLocation: UILabel!
    
    @IBOutlet weak var lblCallingTitle: UILabel!
    
    @IBOutlet weak var skinCallingView: LoadingView!

    @IBOutlet weak var camView: CameraView!
    
    @IBOutlet weak var viewSwipe: UIView!
    
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
        Bundle.main.loadNibNamed("SelectiveProfileViewer", owner: self, options: nil);
        addSubview(contentView);
        contentView.frame = self.bounds;
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight];
        
        imgPhoto.layer.cornerRadius = imgPhoto.bounds.width / 2;
        imgPhoto.clipsToBounds = true;
        imgPhoto.layer.borderColor = UIColor.red.cgColor;
        imgPhoto.layer.borderWidth = 1;
        
        createGesture();
    }
    
    override func initState() {
        super.initState();
        resetCallingView();
        visibleCallingView(isVisible: false);
    }
    
    override func onActive() {
        if (!isActive) {
            super.onActive();
            setLabels();
            
            if (userInfo? ["playerItem"] != nil) {
                profileViewer.isBlurEffect = true;
                profileViewer.createProfileViewer(p_playerItem: userInfo? ["playerItem"] as! CachingPlayerItem,
                                                  p_avPlayer: userInfo? ["avPlayer"] as! AVQueuePlayer);
            }
            Extern.mainVC?.sLoadingPage.requestState = .BeforeRequest;
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                Extern.mainVC?.sLoadingPage.startRequest();
            }
        }
    }
    
    override func onDeactive() {
        if (isActive) {
            super.onDeactive();
            
            visibleCallingView(isVisible: false);
            
            profileViewer.freeState();
            userInfo?.removeAll();
            userInfo = nil;
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        profileViewer.frame = bounds;
//        profileViewer.avPlayerLayer?.frame = bounds;
        profileViewer.resizePlayerLayer(frame: bounds);
    }
    
    func setLabels() {
        if (Extern.isOffline) { return }
        
        if (userInfo! ["photoUrl"] == nil) { return }
        
        imgPhoto.setImage(url: URL(string: userInfo! ["photoUrl"] as! String), defaultImgName: Assets.Default_User_Image);
        
        lblUserName.text = userInfo? ["firstName"] as? String;
        
        let phoneNumber: String = userInfo? ["phoneNumber"] as! String;
        
        let indexStartOfText: String.Index = phoneNumber.index(phoneNumber.startIndex, offsetBy: phoneNumber.count - 10)
        let phoneExt = "+" + String(phoneNumber[..<indexStartOfText]);
        
        let country: Country = Country(countryCode: userInfo? ["country_code"] as! String, phoneExtension: phoneExt);
        lblUserLocation.text = country.name! + "  " + country.flag!
    }
    
    func createGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tap.numberOfTapsRequired = 2
        self.addGestureRecognizer(tap)
        
        self.isUserInteractionEnabled = true
        self.isMultipleTouchEnabled = true
        
        self.viewSwipe.backgroundColor = UIColor.clear;
    }
    
    func resetCallingView() {
        skinCallingView.setGradBackAlpha(alpha: 0.6);
        skinCallingView.setProgMaxValue(maxValue: CGFloat(TransMng.COUNT_RINGTONE - 1));
        skinCallingView.showLabel(number: TransMng.COUNT_RINGTONE);
        
        camView.backgroundColor = UIColor.clear;
        camView.layer.cornerRadius = 10;
        camView.clipsToBounds = true;
        
        camView.layer.borderColor = UIColor(red: 0, green: 205.0 / 255.0, blue: 255.0 / 255.0, alpha: 1).cgColor;
        camView.layer.borderWidth = 2;
        
        skinCallingView.isHidden = true;
        
        skinCallingView.bringSubview(toFront: lblCallingTitle);
        skinCallingView.bringSubview(toFront: camView);
    }
    
    @objc func doubleTapped(gesture: UISwipeGestureRecognizer) -> Void {
        if (Extern.cupManager.isUsingCup()) {
            startCallWithCup();
        } else {
            Extern.mainVC?.showCupPage({() in
                if (Extern.cupManager.isUsingCup()) {
                    self.startCallWithCup();
                }
            });
        }
    }
    
    func startCallWithCup() {
        visibleCallingView(isVisible: true);
        self.startCall();
        
        skinCallingView.setProgValue(value: 0, duration: 0);
    }
    
    @IBAction func onBtnReport(_ sender: Any) {
        let title = "Would you like to report this user?";
        let message = "Our goal is to create a respectful community.\nWe review the reports very seriously.\nPlease don’t hesitate to report inappropriate behaviors. We will take care of the situation 👮‍♂️";
        
        let actionCont = UIAlertController(title: title, message: message, preferredStyle: .actionSheet);
        
        let action1 = UIAlertAction(title: "Person is nude 🔞", style: .default, handler: onReport)
        let action2 = UIAlertAction(title: "Inappropriate video profile 🙈", style: .default, handler: onReport)
        let action3 = UIAlertAction(title: "There's other reason 🤐", style: .default, handler: onReport)
        let action4 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionCont.addAction(action1);
        actionCont.addAction(action2);
        actionCont.addAction(action3);
        actionCont.addAction(action4);
        
        parentVC?.present(actionCont, animated: true, completion: nil);
    }
    
    func onReport(action: UIAlertAction) {
        let id = userInfo! ["id"] as! Int;
        Extern.transMng.reportUser(id: id, report: action.title!);
    }
    
    //isVisible : false     Show => hide
    //          : true      hide => show
    func visibleCallingView(isVisible: Bool) {
        skinCallingView.alpha = isVisible ? 0 : 1;
        skinCallingView.isHidden = false;
        if (isVisible) {
            _ = camView.setupAVCapture();
//            parentController.allowToMove(isAllow: false);
        } else {
            camView.stopCamera();
//            parentController.allowToMove(isAllow: true);
        }
        
        UIView.animate(withDuration: 0.5, animations: {
            self.skinCallingView.alpha = isVisible ? 1.0 : 0.0;
        }, completion: {finished in
            self.skinCallingView.isHidden = !isVisible;
        })
    }
    
    func startCall() {
        Extern.transMng.callingDelegate = self;
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
                self.visibleCallingView(isVisible: false);
            }));
            callingRemainSec = -1;
            parentVC?.present(alert, animated: true, completion: nil)
            return;
        }
        let result: Int = data ["result"] as! Int;
        let callee: String = data ["callee"] as! String;
        let remainSec: Int = data ["remainSec"] as! Int;
        
        if (callee != userInfo! ["phoneNumber"] as! String) {
            return;
        }
        
        if (result == -1) {
            //Refuse call in callee.
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Calling Result", message: data ["message"] as? String, preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_:UIAlertAction) -> Void in
                    self.visibleCallingView(isVisible: false);
                }));
                
                self.parentVC?.present(alert, animated: true, completion: nil)
            }
            Extern.transMng.userStatus = .Logined;
            callingRemainSec = -1;
        } else if (result == 0) {
            if (remainSec == 0) {
                //Timeout...
                DispatchQueue.main.async {
                    self.visibleCallingView(isVisible: false);
                }
                Extern.transMng.userStatus = .Logined;
            } else {
                //Showing seconds.
                DispatchQueue.main.async {
                    let showProg: CGFloat = CGFloat(TransMng.COUNT_RINGTONE - remainSec);
                    
                    self.skinCallingView.showLabel(number: remainSec - 1);
                    self.skinCallingView.setProgValue(value: showProg, duration: 1.8);
                }
            }
            createRingtonMark(remainSec: remainSec);
        } else if (result == 1) {
            Extern.transMng.userStatus = .ReadyCall;
            
            Extern.mainVC?.chattingPage.userInfo = nil;
            Extern.mainVC?.chattingPage.userType = nil;
            
            userInfo? ["playerItem"] = nil;
            userInfo? ["avPlayer"] = nil;
            
            Extern.mainVC?.willStartChat(userInfo: userInfo, userType: .Caller, state: .Selective_Chat);
            callingRemainSec = -1;
        }
    }
    
    func createRingtonMark(remainSec: Int) {
        self.callingRemainSec = remainSec;
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if (remainSec  == self.callingRemainSec) {
                Extern.transMng.resetState();
                DispatchQueue.main.async {
                    self.visibleCallingView(isVisible: false);
                }
            }
        };
    }
}

//
//  RandomProfilePage.swift
//  GriitChat
//
//  Created by GoldHorse on 7/24/18.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit


class RandomProfilePage: ViewPage, TransMngRandomDelegate {
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet var profileViewer: ProfileViewer!
    
    @IBOutlet weak var imgPhoto: UIImageView!
    
    @IBOutlet weak var lblUserName: UILabel!
    
    @IBOutlet weak var lblUserLocation: UILabel!
    
    var userInfo: Dictionary<String, Any>? = nil;
    var videoPath: String? = nil;
    var userType: ChatCoreViewer.UserType!;
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        commonInit();
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        commonInit();
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("RandomProfilePage", owner: self, options: nil);
        addSubview(contentView);
        contentView.frame = self.bounds;
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight];
        
        imgPhoto.layer.cornerRadius = imgPhoto.bounds.width / 2;
        imgPhoto.clipsToBounds = true;
        imgPhoto.layer.borderColor = UIColor.red.cgColor;
        imgPhoto.layer.borderWidth = 1;
    }
    
    override func initState() {
        super.initState();
    }
    
    override func onActive() {
        if (!isActive) {
            super.onActive();
            Extern.mainVC?.camView.stopCamera();
            setLabels();
            
            if (videoPath != nil) {
                profileViewer.isBlurEffect = true;
                profileViewer.createProfileViewer(videoPath: videoPath!);
            }
            Extern.transMng.randomDelegate = self;
            
            if (userType == .Caller) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    if (Extern.transMng.userStatus == .Logined) { return }
                    self.startChatting();
                }
            }
            Extern.transMng.userStatus = .WaitingCall;
        }
    }
    
    override func onDeactive() {
        if (isActive) {
            super.onDeactive();
            
            userInfo?.removeAll();
            userInfo = nil;
            
            videoPath?.removeAll();
            profileViewer.freeState();
            
            Extern.transMng.randomDelegate = nil;
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        profileViewer.frame = bounds;
        profileViewer.resizePlayerLayer(frame: bounds);
    }
    
    func setLabels() {
        if (Extern.isOffline) { return }
        if (userInfo! ["photo"] as! String == "") {
            imgPhoto.image = UIImage(named: Assets.Default_User_Image);
        } else {
            imgPhoto.image = UIImage.base64_2Image(base64Str: userInfo! ["photo"] as! String)
        }
        
        lblUserName.text = userInfo? ["firstName"] as? String;
        
        let phoneNumber: String = userInfo? ["phoneNumber"] as! String;
        
        let indexStartOfText: String.Index = phoneNumber.index(phoneNumber.startIndex, offsetBy: phoneNumber.count - 10)
        let phoneExt = String(phoneNumber[..<indexStartOfText]);
        
        let country: Country = Country(countryCode: userInfo? ["country_code"] as! String, phoneExtension: phoneExt);
        lblUserLocation.text = country.name! + "  " + country.flag!
    }
    
    func startChatting() {
        //Set Chatting Page user info.////.////////
        Extern.transMng.userStatus = .ReadyCall;
        Extern.mainVC?.gotoPage(.Random_Chat);
        Extern.mainVC?.chattingPage.isReceivedIncomingCall = false;
    }
    
    /*func onIncomingCall(message: Dictionary<String, Any>) {
//        Extern.mainVC?.startRandomChatting();
        
//        RandomMainViewController.showMainRandom(view: view, navState: .Init_Chat_Loading, isAnimation: true);
    }*/
    
    func onStartRandomResponse(result: Int, data: Dictionary<String, Any>) {
        if (result == -1) {
//            parentVC?.showMessage(title: "Random Mode", content: data ["message"] as! String, completion: {
                Extern.transMng.resetState();
                Extern.mainVC?.gotoPage(.Random_Loading);
//            });
        }
    }
    func onReadyRandomCallee(result: Int) {
        
    }
    
}


//
//  RandomLoadingPage.swift
//  GriitChat
//
//  Created by GoldHorse on 7/24/18.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit

class RandomLoadingPage: ViewPage, TransMngRandomDelegate, TransMngUserInfoDelegate, CachingPlayerItemDelegate {
    
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var loadingView: LoadingView!
    
    var isRecvBinary = false;
    var userInfo: Dictionary<String, Any>? = nil;
    var userType: ChatCoreViewer.UserType = .Caller;
    
    var playerItem: CachingPlayerItem? = nil;
    var avPlayer: AVQueuePlayer? = nil;
    
    var isReadyPlayerItem = false;
    var isReadyCallee = false;
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        commonInit();
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        commonInit();
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("RandomLoadingPage", owner: self, options: nil);
        addSubview(contentView);
        contentView.frame = self.bounds;
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight];
        
        // Do any additional setup after loading the view.
        loadingView.setGradBackAlpha(alpha: 0.35);
        loadingView.showGlobe(alpha: 0.7);
    }
    
    override func initState() {
        super.initState();
        
        isRecvBinary = false;
        isReadyCallee = false;
        loadingView.setProgValue(value: 0, duration: 0);
    }
    
    override func onActive() {
        if (!isActive) {
            super.onActive();
            Extern.mainVC?.camView.setupAVCapture();
            Extern.mainVC?.camView.isHidden = false;
            Extern.transMng.randomDelegate = self;
            Extern.mainVC?.mainState = .Random_Loading;
            userInfo = nil;
            
            Extern.transMng.startRandom(filter: Extern.cupManager.filterMode.rawValue);
        }
    }
    
    override func onDeactive() {
        if (isActive) {
            super.onDeactive();
            Extern.transMng.userInfoDelegate = nil;
            Extern.transMng.randomDelegate = nil;
            playerItem = nil;
            avPlayer = nil;
            isReadyPlayerItem = false;
//            Extern.mainVC?.camView.stopCamera();
/*
            if (Extern.mainVC?.mainState != .Random_Init) {
                Extern.mainVC?.camView.stopCamera();
            }
            Extern.mainVC?.camView.isHidden = true;*/
        }
    }
    
    func onStartRandomResponse(result: Int, data: Dictionary<String, Any>) {
        if (result == -1) {
            //Not online user...
            parentVC?.showNetworkErrorMessage(completion: {
                self.onDeactive();
                Extern.transMng.logout();
                self.parentVC?.navigationController?.popToRootViewController(animated: true);
            })
            //Failed.
            /*parentVC?.showMessage(title: "Random Mode", content: data ["message"] as! String, completion: {
                Extern.mainVC?.gotoPage(.Random_Init);
            });*/
        } else if (result == 0) {
            //Other user stopped Random mode.
            Extern.mainVC?.gotoPage(.Random_Loading);
        } else if (result == 1) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if (!self.isActive || self.userInfo != nil) { return }
                Extern.transMng.startRandom(filter: Extern.cupManager.filterMode.rawValue);
            }
        } else if (result == 3 || result == 4) {
            if (Extern.mainVC?.mainState == .Random_Loading) {
                self.userInfo = data;
                self.userType = result == 4 ? .Caller : .Callee;
                startLoadVideo();
            }
        }
    }
    
    func startLoadVideo() {
        loadingView.setProgValue(value: 90, duration: 3);
        Extern.transMng.userInfoDelegate = self;
        Extern.transMng.randomDelegate = self;
        
        
        let videoPath: String = userInfo? ["videoPath"] as! String;
        if (videoPath == "") {
            onDeactive();
            onActive();
            return;
        }
        
        playerItem = CachingPlayerItem(url: URL(string: videoPath)!);
        playerItem?.delegate = self;
        avPlayer = AVQueuePlayer(items: [playerItem!]);
//        Extern.transMng.getVideoProfile(id: userId);
    }
    
    func playerItemReadyToPlay(_ playerItem: CachingPlayerItem) {
        userInfo? ["playerItem"] = playerItem;
        userInfo? ["avPlayer"] = avPlayer;
        
        isReadyPlayerItem = true;
        
        if (userType == .Callee) {
            //Send ready message to caller
            _ = Extern.transMng.sendMessage(msg: ["id": "readyRandomCallee",
                                                  "phoneNumber": userInfo! ["phoneNumber"] as! String]);
            
            onCompleteLoading();
        }
        if (isReadyCallee && userType == .Caller) {
            onCompleteLoading();
        }
    }
    
    
    //Only in caller.
    func onReadyRandomCallee(result: Int) {
        if (result == 1) {
            //For Caller
            isReadyCallee = true;
            if (isReadyPlayerItem && userType == .Caller) {
                onCompleteLoading();
            }
        } else if (result == 0 && userType == .Callee) {
            //For Callee (failed)
            avPlayer?.removeAllItems();
            playerItem = nil;
            
            Extern.transMng.resetState();
            onDeactive();
            onActive();
        }
    }
    
    func onCompleteLoading() {
        Extern.mainVC?.onDidRandomLoading(result: true, userInfo: userInfo, userType: userType, error: nil);
        userInfo?.removeAll();
        userInfo = nil;
    }
    
    /*func onRecvBinary(data: Data) {
        if (isRecvBinary) {
            return;
        }
        var tmpVideoPath: String? = NSTemporaryDirectory().appending("profile.mov");
        FileManager.deleteFile(filePath: tmpVideoPath!);
        
        do {
            try data.write(to: URL(fileURLWithPath: tmpVideoPath!));
        } catch let e {
            tmpVideoPath = nil;
            debugPrint(e.localizedDescription);
        }
        
        isRecvBinary = true;
        Extern.mainVC?.onDidRandomLoading(result: true, userInfo: userInfo, videoPath: tmpVideoPath, userType: userType, error: nil);
        
        userInfo?.removeAll();
        userInfo = nil;
        tmpVideoPath?.removeAll();
        tmpVideoPath = nil;
    }
    
    func onRecvVideoProfileResult(result: Bool, message: String?) {
        if (!result) {
            Extern.mainVC?.onDidRandomLoading(result: false, userInfo: nil, videoPath: nil, userType: nil, error: message);
        }
    }*/
    
}


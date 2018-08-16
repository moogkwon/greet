//
//  SelectiveLoadingPage.swift
//  GriitChat
//
//  Created by leo on 24/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit

class SelectiveLoadingPage: ViewPage, TransMngUserInfoDelegate, CachingPlayerItemDelegate {

    @IBOutlet var contentView: UIView!
    @IBOutlet var loadingView: LoadingView!
    @IBOutlet weak var imgNotify: UIImageView!
    
    var userInfo: Dictionary<String, Any>? = nil;
    
    enum RequestingState {
        case BeforeRequest;
        case Requesting;
        case AfterRequest;
    };
    
    var requestState: RequestingState = .BeforeRequest;
    
    var playerItem: CachingPlayerItem? = nil;
    var avPlayer: AVQueuePlayer? = nil;
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        commonInit();
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        commonInit();
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("SelectiveLoadingPage", owner: self, options: nil);
        addSubview(contentView);
        contentView.frame = self.bounds;
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight];
        
        loadingView.setGradBackAlpha(alpha: 1);
        loadingView.showGlobe(alpha: 0.5);
    }
    
    override func initState() {
        loadingView.setProgValue(value: 0, duration: 0);
//        userInfo?.removeAll();
    }
    
    override func onActive() {
        if (!isActive) {
            super.onActive();
            Extern.transMng.resetState();
            
            //Especially, active Selective.
            Extern.mainVC?.sToolbarView.setActive(tabName: .Selective);
            Extern.mainVC?.camView.stopCamera();
            
            startRequest();
        }
    }
    
    override func onDeactive() {
        if (isActive) {
            super.onDeactive();
            initState();
//            self.requestState = .BeforeRequest;
        }
    }
    
    func startRequest() {
        Extern.transMng.userInfoDelegate = self;

        debugPrint("requestState: ", requestState);
        
        if (requestState == .BeforeRequest || userInfo == nil || userInfo?.count == 0) {
            requestState = .Requesting
            userInfo?.removeAll();
            Extern.transMng.getUserInfos(filter: Extern.cupManager.filterMode.rawValue);
        } else if (requestState == .AfterRequest) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.onCompleteLoading();
            }
        }
    }
    
    func onUserInfoReceived(result: Int, data: Dictionary<String, Any>?, message: String?) {
        if (result > 0) {
            loadingView.setProgValue(value: 90, duration: 2);
//            Extern.transMng.getVideoProfile(id: data? ["id"] as! Int);

            userInfo?.removeAll();
            userInfo = data;
            
            let videoPath: String = userInfo? ["videoPath"] as! String;
            if (videoPath == "") {
                requestState = .BeforeRequest;
                startRequest();
                return;
            }
            
            playerItem = CachingPlayerItem(url: URL(string: videoPath)!);
            playerItem?.delegate = self;
            avPlayer = AVQueuePlayer(items: [playerItem!]);
        } else {
            requestState = .BeforeRequest;
            
            //Retry request.....
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if (Extern.mainVC?.mainState.rawValue != self.pageName) { return }
                if (self.requestState != .BeforeRequest) { return }
                
                self.requestState = .Requesting;
                Extern.transMng.getUserInfos(filter: Extern.cupManager.filterMode.rawValue);
            }
//            parentVC?.showMessage(title: "Error", content: message!, completion: nil);
        }
    }
    
    func playerItemReadyToPlay(_ playerItem: CachingPlayerItem) {
        self.requestState = .AfterRequest;
        
        if (Extern.mainVC?.mainState == .Selective_Loading) {
            onCompleteLoading();
        }
    }
    
    func onCompleteLoading() {
        userInfo? ["playerItem"] = playerItem;
        userInfo? ["avPlayer"] = avPlayer;
        
        Extern.mainVC?.onDidSelectiveLoading(result: true, userInfo: userInfo, error: nil);
        
        userInfo?.removeAll();
        userInfo = nil;
        playerItem = nil;
        avPlayer = nil;
    }
}

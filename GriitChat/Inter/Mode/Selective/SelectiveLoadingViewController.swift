//
//  SelectiveLoadingViewController.swift
//  GriitChat
//
//  Created by leo on 16/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class SelectiveLoadingViewController: CalleeViewController, TransMngUserInfoDelegate {

//    var parent: SelectiveMainViewController!;
    
    @IBOutlet var loadingView: LoadingView!
    
    @IBOutlet weak var imgNotify: UIImageView!
    
    var userInfo: Dictionary<String, Any>? = nil;
    
    var parentController: SelectiveMainViewController? = nil;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingView.setGradBackAlpha(alpha: 1);
        loadingView.showGlobe(alpha: 0.5);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
//        sToolbarView.setActive(tabName: .Selective)
        
        view.addSubview(imgNotify);
    }
    
    func startLoad() {
        debugPrint("Before send getUserInfos :  ", Extern.getMemoryUsage());
        Extern.transMng.userInfoDelegate = self;
//        Extern.transMng.getUserInfos(mode: .Selective);
        
        debugPrint("After send getUserInfos :  ", Extern.getMemoryUsage());
    }
    
    func onUserInfoReceived(data: Dictionary<String, Any>) {
        loadingView.setProgValue(value: 90, duration: 0.5);
        Extern.transMng.getVideoProfile(id: data ["id"] as! Int);
        userInfo?.removeAll();
        userInfo = data;
        debugPrint("After Receive User Info :  ", Extern.getMemoryUsage());
    }
    
    var isRecvBinary = false;
    func onRecvBinary(data: Data) {
        
        debugPrint("Received user profile :  ", Extern.getMemoryUsage());
        
        if (isRecvBinary) {
            return;
        }
        //Extern.makeTempPath("mov");
        let tmpVideoPath: String = FileManager.makeTempPath("mov"); // NSTemporaryDirectory().appending("profile.mov");
        //FileManager.default.createFile(atPath: tmpVideoPath, contents: nil, attributes: nil);
        
        debugPrint(tmpVideoPath);
        FileManager.deleteFile(filePath: tmpVideoPath);
        
        do {
            try data.write(to: URL(fileURLWithPath: tmpVideoPath));
            
            debugPrint("Saved user profile :  ", Extern.getMemoryUsage());
            
            isRecvBinary = true;
            
            Extern.chat_userInfo = userInfo;
            Extern.chat_videoPath = tmpVideoPath;
            SelectiveMainViewController.showMainSelective(view: self.view, navState: .Profile_Loading, isAnimation: true);
            
            debugPrint("Show profile page :  ", Extern.getMemoryUsage());
            
        } catch let e {
            showMessage(title: "Video Profile error", content: "Video Profile save error");
            debugPrint(e.localizedDescription);
        }
    }

    func onRecvVideoProfileResult(result: Bool, message: String?) {
        if (!result) {
            showMessage(title: "Video Profile error", content: message!);
            return;
        }
    }
}

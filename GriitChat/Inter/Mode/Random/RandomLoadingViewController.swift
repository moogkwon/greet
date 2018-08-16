//
//  RandomLoadingViewController.swift
//  GriitChat
//
//  Created by leo on 17/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit

class RandomLoadingViewController: CalleeViewController, TransMngUserInfoDelegate {
    
    @IBOutlet weak var loadingView: LoadingView!
    
    var parentController: RandomMainViewController!;
    
    var isRecvBinary = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadingView.setGradBackAlpha(alpha: 0.35);
        loadingView.showGlobe(alpha: 0.5);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startLoad() {
//        Extern.transMng.startRandom();
    }
    
    func startLoadVideo(userId: Int) {
        loadingView.setProgValue(value: 90, duration: 3);
        Extern.transMng.getVideoProfile(id: userId);
        Extern.transMng.userInfoDelegate = self;
    }
    
    func onRecvBinary(data: Data) {
        if (isRecvBinary) {
            return;
        }
        let tmpVideoPath: String = NSTemporaryDirectory().appending("profile.mov");
        FileManager.deleteFile(filePath: tmpVideoPath);
        
        do {
            try data.write(to: URL(fileURLWithPath: tmpVideoPath));
            
            isRecvBinary = true;
            parentController.onRecvVideoComplete(result: true, videoPath: tmpVideoPath);
        } catch let e {
            showMessage(title: "Video Profile error", content: "Video Profile save error", completion: {
                self.parentController.onRecvVideoComplete(result: false, videoPath: nil);
            });
            debugPrint(e.localizedDescription);
        }
    }
    
    func onRecvVideoProfileResult(result: Bool, message: String?) {
        if (!result) {
            showMessage(title: "Video Profile error", content: message!, completion: {
                self.parentController.onRecvVideoComplete(result: false, videoPath: nil);
            });
            return;
        }
    }
    
}

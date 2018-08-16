//
//  ProfileViewer.swift
//  GriitChat
//
//  Created by leo on 20/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class ProfileViewer: UIView, CachingPlayerItemDelegate {

    var videoPath: String!;
    
    var isCreatedPlayer = false;

    var avPlayer: AVQueuePlayer!
    var avPlayerLayer_real: AVPlayerLayer? = nil;
    var avPlayerLayer_blur: AVPlayerLayer? = nil;
    
    var avPlayerLooper: AVPlayerLooper? = nil;
    
    var playerItem: CachingPlayerItem? = nil;
    
//    var timeObserver: AnyObject! = nil;
    var startTime = 0.0;
    var endTime = 0.0;
    
    var isLayoutVideo = false;
    
    var isBlurEffect: Bool = false;
    
    var blurPlayerView: UIView? = nil;
    var realPlayerView: UIView? = nil;
    var blurEffectView: UIVisualEffectView? = nil;
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        commonInit();
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        commonInit();
    }
    
    func commonInit() {
        blurPlayerView = UIView(frame: bounds);
        addSubview(blurPlayerView!);
        blurPlayerView?.backgroundColor = UIColor.clear;
        
        realPlayerView = UIView(frame: bounds);
        addSubview(realPlayerView!);
        realPlayerView?.backgroundColor = UIColor.clear;
    }
    
    func freeState() {
        if (avPlayer != nil) {
            avPlayerLayer_real?.removeFromSuperlayer();
            avPlayerLayer_blur?.removeFromSuperlayer();
            blurEffectView?.removeFromSuperview();
            
//            avPlayer.removeTimeObserver(timeObserver);
            avPlayer.pause();
            avPlayer.removeAllItems();
//            timeObserver = nil;
            
            avPlayerLooper = nil;
            
            playerItem = nil;
        }
        avPlayer = nil;
        avPlayerLayer_real = nil;
        avPlayerLayer_blur = nil;
        blurEffectView = nil;
        isCreatedPlayer = false;
        
        startTime = 0.0;
        endTime = 0.0;
        isLayoutVideo = false;
        isBlurEffect = false;
    }
    
    func createProfileViewer(videoPath: String) {
        if (isCreatedPlayer) {
            return;
        }
        if (videoPath == "") { return }
        
        //let playerItem = AVPlayerItem(url: URL(fileURLWithPath: videoPath));
//        let url = URL(string: "http://192.168.42.1:8443/video/22.mp4")!
        
        playerItem = CachingPlayerItem(url: URL(string: videoPath)!);
        playerItem?.delegate = self;
        avPlayer = AVQueuePlayer(items: [playerItem!]);
        
        createViews();
    }
    
    func createProfileViewer(p_playerItem: CachingPlayerItem, p_avPlayer: AVQueuePlayer) {
        self.playerItem = p_playerItem;
        self.avPlayer = p_avPlayer;
        
        self.playerItem?.delegate = self;
        createViews();
    }
    
    func createViews() {
        avPlayerLooper = AVPlayerLooper(player: avPlayer, templateItem: playerItem!)

        avPlayerLayer_real = AVPlayerLayer(player: avPlayer)
        realPlayerView?.layer.insertSublayer(avPlayerLayer_real!, at: 1)
        avPlayerLayer_real?.frame = self.bounds;
        
        if (isBlurEffect) {
            avPlayerLayer_blur = AVPlayerLayer(player: avPlayer)
            blurPlayerView?.layer.insertSublayer(avPlayerLayer_blur!, at: 1)
            avPlayerLayer_blur?.frame = self.bounds;
            
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.regular)
            blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView?.frame = bounds
            blurEffectView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            blurPlayerView?.addSubview(blurEffectView!)
        }
        
        isCreatedPlayer = true;
        avPlayer.play();
        isLayoutVideo = false;
    }
    
    func playerItemReadyToPlay(_ playerItem: CachingPlayerItem) {
        debugPrint("Ready to play: ", Date().timeIntervalSince1970);
        resizePlayerLayer(frame: bounds);
    }
    
    func resizePlayerLayer(frame: CGRect) {
        if (avPlayerLayer_real == nil) { return }

        let size: CGSize = (playerItem?.presentationSize)!;
        if (size.width == 0 || size.height == 0) { return }
        
        isLayoutVideo = true;
        
        realPlayerView?.frame = frame;
        
        let newFrame = Extern.getAspectFitRect(orgSize: size, tgtSize: frame.size);
        
        if (!isBlurEffect) {
            avPlayerLayer_real?.frame = newFrame;
        } else if (avPlayerLayer_blur != nil) {
            blurPlayerView?.frame = frame;
            avPlayerLayer_blur?.frame = newFrame;
            avPlayerLayer_real?.frame = frame;
        }
    }
}

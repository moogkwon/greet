//
//  VideoTrimViewController.swift
//  GriitChat
//
//  Created by leo on 11/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit


class VideoTrimViewController: UIViewController, UIGestureRecognizerDelegate, SAVideoRangeSliderDelegate, TransMngUploadVideoDelegate {
    
    @IBOutlet var videoContainer: UIView!
    
    @IBOutlet var mVideoRangeView: UIView!
    
    var mySAVideoRangeSlider: SAVideoRangeSlider?;
    
    var avPlayer: AVPlayer? = nil
    var avPlayerLayer: AVPlayerLayer? = nil
    var timeObserver: AnyObject? = nil
    var startTime = 0.0;
    var endTime = 0.0;
    var progressTime = 0.0;
    var shouldUpdateProgressIndicator = true
    var isSeeking = false
    
    var videoUrl: URL?;     //Org
    
    var tmpVideoPath: String = "";      //Trimed video
    
    var isWhenLoginFirst: Bool = true;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backView: GradientView = super.view as! GradientView;
        backView.setBackColors(colors: [UIColor.dodgerBlue.cgColor, UIColor.brightLightBlue.cgColor]);
        
        avPlayer = AVPlayer();
        let playerItem = AVPlayerItem(url: videoUrl!)
        avPlayer?.replaceCurrentItem(with: playerItem)
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        
        videoContainer.layer.insertSublayer(avPlayerLayer!, at: 0)
        videoContainer.layer.masksToBounds = true
        
        self.endTime = CMTimeGetSeconds((avPlayer?.currentItem?.duration)!)
        let timeInterval: CMTime = CMTimeMakeWithSeconds(0.01, 100)
        timeObserver = avPlayer?.addPeriodicTimeObserver(forInterval: timeInterval,
                                                        queue: DispatchQueue.main) { (elapsedTime: CMTime) -> Void in
                                                            self.observeTime(elapsedTime: elapsedTime) } as AnyObject!
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self;
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false;
        
        self.activiityIndicator.isHidden = true;
        avPlayer?.play();
        
        
        videoContainer.layer.cornerRadius = 20;
        videoContainer.clipsToBounds = true;
        
        btnTrimVideo.clipsToBounds = true;
        
        navigationController?.navigationBar.isHidden = false;
        navigationController?.navigationBar.barTintColor = UIColor.dodgerBlue;
        
        Extern.transMng.uploadVideoDelegate = self;
        
        tmpVideoPath = FileManager.makeTempPath("mov");
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews();
        btnTrimVideo.layer.cornerRadius = btnTrimVideo.frame.height / 2;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationController?.navigationBar.isHidden = false;
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        self.navigationController?.navigationBar.isHidden = true;
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true;
        self.navigationController?.navigationBar.isHidden = true;
        
        freeState();
    }
    
    func freeState() {
        if (avPlayer != nil) {
            avPlayerLayer?.removeFromSuperlayer();
            avPlayer?.removeTimeObserver(timeObserver);
            avPlayer?.pause();
            timeObserver = nil;
        }
        avPlayer = nil;
        avPlayerLayer = nil;
        
        startTime = 0.0;
        endTime = 0.0;
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avPlayerLayer?.frame = videoContainer.bounds
        
        createVideoSlider();
    }
    
    func createVideoSlider() {
        let rangeFrame: CGRect = self.mVideoRangeView.frame;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad) {
            self.mySAVideoRangeSlider = SAVideoRangeSlider(frame: rangeFrame, videoUrl: videoUrl);
            self.mySAVideoRangeSlider?.setPopoverBubbleSize(200, height: 100);
            
        } else {
            self.mySAVideoRangeSlider = SAVideoRangeSlider(frame: rangeFrame, videoUrl: videoUrl);
            self.mySAVideoRangeSlider?.bubleText.font = UIFont.systemFont(ofSize: 12);
            self.mySAVideoRangeSlider?.setPopoverBubbleSize(120, height: 60);
            // self.mySAVideoRangeSlider.maxGap=30;
        }
        
        //Yellow
        /*
        self.mySAVideoRangeSlider?.topBorder.backgroundColor = UIColor.init(red: 0.992, green: 0.902, blue: 0.004, alpha: 1);
        self.mySAVideoRangeSlider?.bottomBorder.backgroundColor = UIColor.init(red: 0.992, green: 0.902, blue: 0.004, alpha: 1);*/
        
        
        self.mySAVideoRangeSlider?.topBorder.backgroundColor = UIColor.init(red: 0.945, green: 0.945, blue: 0.945, alpha: 1);
        self.mySAVideoRangeSlider?.bottomBorder.backgroundColor = UIColor.init(red: 0.806, green: 0.806, blue: 0.806, alpha: 1);
        
        self.mySAVideoRangeSlider?.delegate = self;
        
        //        self.view.addSubview(self.mySAVideoRangeSlider!);
        self.view.addSubview(self.mySAVideoRangeSlider!);
        //        self.mySAVideoRangeSlider?.bounds = self.mVideoRangeView.bounds;
        
        /*mySAVideoRangeSlider?.translatesAutoresizingMaskIntoConstraints = false;
        
        let horzCon = NSLayoutConstraint(item: mySAVideoRangeSlider!, attribute: .centerX, relatedBy: .equal, toItem: mVideoRangeView, attribute: .centerX, multiplier: 1, constant: 0);
        let vertCon = NSLayoutConstraint(item: mySAVideoRangeSlider, attribute: .centerY, relatedBy: .equal, toItem: mVideoRangeView, attribute: .centerY, multiplier: 1, constant: 0);
        let widthCon = NSLayoutConstraint(item: mySAVideoRangeSlider, attribute: .width, relatedBy: .equal, toItem: mVideoRangeView, attribute: .width, multiplier: 1, constant: 0)
        let heightCon = NSLayoutConstraint(item: mySAVideoRangeSlider, attribute: .height, relatedBy: .equal, toItem: mVideoRangeView, attribute: .height, multiplier: 1, constant: 0)
        mVideoRangeView.addConstraints([horzCon, vertCon, widthCon, heightCon]);*/
        
//        self.mVideoRangeView.isHidden = true;
        self.mVideoRangeView.backgroundColor = nil;
        
        //        self.mySAVideoRangeSlider?.frame = self.mVideoRangeView.frame
    }
    
    private func observeTime(elapsedTime: CMTime) {
        //let elapsedTime = CMTimeGetSeconds(elapsedTime)
        
        if ((avPlayer?.currentTime().seconds)! > self.endTime){
            let timescale = self.avPlayer?.currentItem?.asset.duration.timescale
            let time = CMTimeMakeWithSeconds(self.startTime, timescale!)
            avPlayer?.seek(to: time)
            avPlayer?.play();
        }
        
        if self.shouldUpdateProgressIndicator{
//            rangeSlider.updateProgressIndicator(seconds: elapsedTime)
        }
    }
    
    func videoRange(_ videoRange: SAVideoRangeSlider!, didChangeLeftPosition leftPosition: CGFloat, rightPosition: CGFloat) {
        self.endTime = Double(rightPosition);
        
        if Double(leftPosition) != self.startTime {
            self.startTime = Double(leftPosition);
            
            let timescale = self.avPlayer?.currentItem?.asset.duration.timescale
            let time = CMTimeMakeWithSeconds(self.startTime, timescale!)
            if !self.isSeeking{
                self.isSeeking = true
                avPlayer?.seek(to: time, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero){_ in
                    self.isSeeking = false
                }
            }
        }
        avPlayer?.play();
        
        // Pause the player
        /*avPlayer.pause()
        btnPlay.isEnabled = true
        btnPause.isEnabled = false
        self.shouldUpdateProgressIndicator = false*/
    }
    
    /*func indicatorDidChangePosition(videoRangeSlider: ABVideoRangeSlider, position: Float64) {
        self.shouldUpdateProgressIndicator = false
        
        // Pause the player
        avPlayer.pause()
        btnPlay.isEnabled = true
        btnPause.isEnabled = false
        
        if self.progressTime != position {
            self.progressTime = position
            let timescale = self.avPlayer.currentItem?.asset.duration.timescale
            let time = CMTimeMakeWithSeconds(self.progressTime, timescale!)
            if !self.isSeeking{
                self.isSeeking = true
                avPlayer.seek(to: time, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero){_ in
                    self.isSeeking = false
                }
            }
        }
        
    }
    
    func didChangeValue(videoRangeSlider: ABVideoRangeSlider, startTime: Float64, endTime: Float64) {
        
        self.endTime = endTime
        
        if startTime != self.startTime{
            self.startTime = startTime
            
            let timescale = self.avPlayer.currentItem?.asset.duration.timescale
            let time = CMTimeMakeWithSeconds(self.startTime, timescale!)
            if !self.isSeeking{
                self.isSeeking = true
                avPlayer.seek(to: time, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero){_ in
                    self.isSeeking = false
                }
            }
        }
    }*/
    
    
    var exportSession: AVAssetExportSession?;
    
    
    @IBOutlet weak var btnTrimVideo: UIButton!
    
    @IBOutlet weak var activiityIndicator: UIActivityIndicatorView!
    
    @IBAction func onBtnTrim(_ sender: Any) {
        FileManager.deleteFile(filePath: tmpVideoPath);
        
        let anAsset: AVAsset = AVURLAsset.init(url: videoUrl!, options: nil);
        let compatiblePresets: [String] = AVAssetExportSession.exportPresets(compatibleWith: anAsset);
        if (compatiblePresets.contains(AVAssetExportPresetMediumQuality)) {
            self.exportSession = AVAssetExportSession.init(asset: anAsset, presetName: AVAssetExportPresetLowQuality);
            
            self.exportSession?.outputURL = URL.init(fileURLWithPath: tmpVideoPath);
            self.exportSession?.outputFileType = AVFileType.mov;
            self.exportSession?.shouldOptimizeForNetworkUse = true
            
            let start: CMTime = CMTimeMakeWithSeconds(self.startTime, anAsset.duration.timescale);
            let duration: CMTime = CMTimeMakeWithSeconds(self.endTime - self.startTime, anAsset.duration.timescale);
            let range: CMTimeRange = CMTimeRangeMake(start, duration);
            self.exportSession?.timeRange = range;
            
            self.restrictControls(value: true);
            
            self.exportSession?.exportAsynchronously(completionHandler: {
                let status: AVAssetExportSessionStatus = (self.exportSession?.status)!;
                switch(status) {
                case AVAssetExportSessionStatus.failed:
                    debugPrint("Export failed: ", self.exportSession?.error?.localizedDescription as String!);
                    self.showMessage(title: "Error", content: "Export failed: " + (self.exportSession?.error?.localizedDescription)! as String!);
                    break;
                case AVAssetExportSessionStatus.cancelled:
                    debugPrint("Export canceled");
                    self.showMessage(title: "Error", content: "Export Cancelled.");
                    break;
                default:
                    debugPrint("None");
                    DispatchQueue.main.async {
                        /*self.btnTrimVideo.isEnabled = true;
                        self.activiityIndicator.isHidden = true;
                        self.activiityIndicator.stopAnimating();*/
                        self.uploadVideo(path: self.tmpVideoPath);
                        
                        /*let tmpUrl = URL.init(fileURLWithPath: tmpVideoPath)
                        let player = AVPlayer(url: tmpUrl)
                        let playerViewController = AVPlayerViewController()
                        playerViewController.player = player
                        self.present(playerViewController, animated: true) {
                            playerViewController.player!.play()
                        }*/
                    }
                    return;
                }
                self.restrictControls(value: false);
            })
        }
    }
    
    func restrictControls(value: Bool) {
        btnTrimVideo.isEnabled = value == false;
        activiityIndicator.isHidden = value == false;
        if (value) {
            self.avPlayer?.pause();
            activiityIndicator.startAnimating();
            self.videoContainer.backgroundColor = UIColor.lightGray;
            self.videoContainer.alpha = 0.6;
        } else {
            self.avPlayer?.play();
            activiityIndicator.stopAnimating();
            self.videoContainer.backgroundColor = UIColor.white;
            self.videoContainer.alpha = 1;
        }
    }
    
    func uploadVideo(path: String) {
        if let stream:InputStream = InputStream(fileAtPath: path) {
            let size = FileManager.fileSize(forURL: path);
            debugPrint("File Size: ", size);
            
            var buf:[UInt8] = [UInt8](repeating: 0, count: Int(size + 1))
            stream.open()
            
            let len = stream.read(&buf, maxLength: buf.count)
            debugPrint("Read Size: ", len);
            
            stream.close()
            
            //Convert [UInt8] to NSData
            let data = NSData(bytes: buf, length: len)
            
            //Encode to base64
            var base64Data = data.base64EncodedString(options: NSData.Base64EncodingOptions.endLineWithLineFeed)
            
            debugPrint("Base64 Size: ", base64Data.count);
            
            Extern.transMng.uploadVideo(videoData: base64Data);
            base64Data.removeAll();
        } else {
            self.showMessage(title: "Error", content: "Input Stream Error.");
            restrictControls(value: false);
        }
    }
    
    func onUploadVideo(result: Bool, message: Dictionary<String, Any>?) {
        if (result) {
            //Success...
            //Remove old file.
            if (UserDefaults.standard.string(forKey: UserKey.Profile_Shared_Key) != nil) {
                let videoPath = UserDefaults.standard.string(forKey: UserKey.Profile_Shared_Key);
                FileManager.deleteFile(filePath: videoPath!);
            }
            
            //Save new video file path.
            UserDefaults.standard.set(tmpVideoPath, forKey: UserKey.Profile_Shared_Key);
            
            UserDefaults.standard.set(true, forKey: "isUploadVideo");
            
            if (isWhenLoginFirst) {
                let allowDevVC = self.storyboard?.instantiateViewController(withIdentifier: "AllowDeviceViewController") as! AllowDeviceViewController;
                
                self.present(allowDevVC, animated: true, completion: nil);
            } else {
                self.navigationController?.popViewController(animated: true);
            }
        } else {
            let strMsg = message! ["message"] as! String
            showMessage(title: "Upload Video Error", content: strMsg);
            
            
            restrictControls(value: false);
        }
    }
}

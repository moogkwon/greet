//
//  RecorderButton.swift
//  GriitChat
//
//  Created by GoldHorse on 7/26/18.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

protocol RecorderButtonDelegate {
    func onTapEnable();
    
    func onRecordStart();
    func onRecordStop(photoPath: String,  videoPath: String);
}

class RecorderButton: UIView {

    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var progressBox: UIView!
    
    @IBOutlet weak var progressBar: UIView!
    
    @IBOutlet weak var btnRecorder: UIView!
    
    @IBOutlet weak var innerRecorderBtn: UIView!
    
    var delegate: RecorderButtonDelegate? = nil;
    
    var isPressed = false;
    
    var longPressRecognizer: UILongPressGestureRecognizer? = nil;
    var tapEnableRecognizer: UITapGestureRecognizer? = nil;
    
    let recordMaxDuration: CGFloat = 30.0;
    var curDuration: CGFloat = 0.0;
    
    var timer: Timer? = nil;
    
    var screenRecorder: RecordScreen? = nil;
    
    var parentVC: UIViewController? = nil;
    
    var isBtnEnabled = false;
    
    var isGetPermission = false;
    
    var photoPath: String = "";
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        commonInit();
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        commonInit();
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("RecorderButton", owner: self, options: nil);
        addSubview(contentView);
        contentView.frame = self.bounds;
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight];
        
        longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        contentView.addGestureRecognizer(longPressRecognizer!)
        
        tapEnableRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapPressed))
        btnRecorder.addGestureRecognizer(tapEnableRecognizer!)
        
        initState();
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        
        btnRecorder.layer.cornerRadius = btnRecorder.bounds.width / 2;
        btnRecorder.layer.borderColor = UIColor.white.cgColor;
        btnRecorder.layer.borderWidth = 1;
        btnRecorder.clipsToBounds = true;
        
        innerRecorderBtn.layer.cornerRadius = innerRecorderBtn.bounds.width / 2;
        innerRecorderBtn.clipsToBounds = true;
    }
    
    func initState() {
        progressBox.isHidden = true;
        setProgress(progress: 0);
        setRecordEnabled(enabled: false);
        
        isPressed = false
        curDuration = 0.0;
        
        screenRecorder = nil;
        
        setRecordEnabled(enabled: false);
        
        isGetPermission = false;
    }
    
    func setRecordEnabled(enabled: Bool) {
        btnRecorder.backgroundColor = enabled ? UIColor.white : UIColor.clear;
        innerRecorderBtn.isHidden = !enabled;
        isBtnEnabled = enabled;
        progressBox.isHidden = !enabled;
    }
    
    //0 ~ 1
    func setProgress(progress: CGFloat) {
        progressBar.frame = CGRect(x: 0, y: 0, width: frame.width * progress, height: progressBar.bounds.height);
    }
    
    @objc func tapPressed(sender: UITapGestureRecognizer) {
        if (!isGetPermission) {
            screenRecorder = RecordScreen();
            screenRecorder?.getPermission { (result: Bool) in
                debugPrint("Get Permission!!!  ", result);
                self.isGetPermission = result;
            }
        }
        if (!isBtnEnabled) {
            delegate?.onTapEnable();
        }
    }
    
    @objc func longPressed(sender: UILongPressGestureRecognizer)
    {
        if (!isBtnEnabled) { return }
        
        let touchLocation = sender.location(in: sender.view?.window)
        if (sender.state == .began && btnRecorder.frame.contains(touchLocation) && !isPressed) {
            startRecording();
        }
        else if (sender.state == .ended && isPressed) {
            DispatchQueue.main.async {
                self.isPressed = false;
                self.stopRecording();
            }
        }
    }
    
    func startRecording() {
        isPressed = true;
        debugPrint("Pressed");
        
        delegate?.onRecordStart();
        
        var isReturned = false;
        visibleControls(visible: false, completion: {()
            self.screenRecorder = RecordScreen();
            self.screenRecorder?.startRecording(onStart: { (result: Bool, error: String?) in
                if (isReturned) { return }
                isReturned = true;
                DispatchQueue.main.async {
                    if (result) {
                        self.curDuration = 0;
                        self.setProgress(progress: 0);
                        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: (#selector(self.updateTimer)), userInfo: nil, repeats: true);
                        
                        //Take screenshot
                        self.photoPath = FileManager.makeTempPath("png");
                        Extern.takeScreenshot()?.saveImage(savePath: self.photoPath)
                    } else {
                        self.stopRecording();
                        debugPrint(error);
                    }
                }
            })
        })
        
    }
    
    func stopRecording() {
        var isReturned = false;
        screenRecorder?.stopRecord { (result: Bool, url: URL?) in
            if (isReturned) { return }
            if (url == nil) { return }
            isReturned = true;
            
            DispatchQueue.main.async {
                self.isPressed = false;
                debugPrint("Endup!", self.curDuration);
                self.timer?.invalidate();
                self.timer = nil;
                self.delegate?.onRecordStop(photoPath: self.photoPath, videoPath: (url?.path)!);
                self.visibleControls(visible: true, completion: nil);
                self.photoPath.removeAll();
                /*
                if (result) {
                    //Play Video
                    let player = AVPlayer(url: url!)
                    let playerController = AVPlayerViewController()
                    playerController.player = player
                    self.parentVC?.present(playerController, animated: true) {
                        player.play()
                    }
                }*/
            }
        }
    }
    
    func visibleControls(visible: Bool, completion: (() -> Void)?) {
        UIView.animate(withDuration: 0.2, animations: {
            self.btnRecorder.alpha = visible ? 1 : 0;
        }, completion: {(result: Bool) in
            completion?();
        });
    }
    
    @objc func updateTimer(timer: Timer) {
        curDuration += 0.1;
        
        
        DispatchQueue.main.async {
            if (self.curDuration >= self.recordMaxDuration) {
                self.timer?.invalidate();
                self.timer = nil;
                self.stopRecording();
                return;
            }
        
            self.setProgress(progress: self.curDuration / self.recordMaxDuration);
        }
    }
}

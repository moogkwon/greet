//
//  VideoRecordingViewController.swift
//  GriitChat
//
//  Created by GoldHorse on 7/12/18.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit
import ReplayKit
import AVKit

class VideoRecordingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        imageView.loadGif(asset: "uploadgif");
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    var screenRecorder: RPScreenRecorder?;
    var assetWriter: AVAssetWriter?;
    var assetWriterInput_: AVAssetWriterInput?;
    var assetWriterInputAudio: AVAssetWriterInput?;
    
    var videoSessionStarted = false;
    var audioSessionStarted = false;
    var isMicEnabled = false;

    @IBAction func onBtnRecord(_ sender: Any) {
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { (granted: Bool) in
            debugPrint("Video Capture Request: ", granted);
            
            AVCaptureDevice.requestAccess(for: AVMediaType.audio, completionHandler: { (granted: Bool) in
                debugPrint("Audio Capture Request: ", granted);
                
                DispatchQueue.main.async {
                    self.isMicEnabled = granted;
                    self.startRecording();
                }
            })
        }
    }
    
    func startRecording() {
        if (!RPScreenRecorder.shared().isAvailable) {
            debugPrint("Screen Recorder is not available!");
            return;
        }
        
        // Prepare asset writer
        let pathDocuments: [String] = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true);
        let outputURL = pathDocuments [0];
        let videoOutPath = outputURL + "/temp.mp4";
        deleteFile(filePath: videoOutPath);
        let fileURL = URL.init(fileURLWithPath: videoOutPath);
        let screenSize = UIScreen.main.bounds.size;
        
        debugPrint("Recording video to " + videoOutPath);
        do {
            self.assetWriter = try AVAssetWriter.init(url: fileURL, fileType: .mp4);
        } catch {
            debugPrint("Asset Writer init error");
            return;
        }
        self.assetWriter?.movieTimeScale = 60;
        
        
        // Video input
        let videoInputSettings = [
            // AVVideoCompressionPropertiesKey: {
            //   AVVideoPixelAspectRatioKey: {
            //     AVVideoPixelAspectRatioVerticalSpacingKey: 1,
            //     AVVideoPixelAspectRatioHorizontalSpacingKey: 1
            //   },
            //   AVVideoCleanApertureKey: {
            //     AVVideoCleanApertureWidthKey: screenSize.width,
            //     AVVideoCleanApertureHeightKey: screenSize.height,
            //     AVVideoCleanApertureVerticalOffsetKey: 10,
            //     AVVideoCleanApertureHorizontalOffsetKey: 10
            //   }
            // },
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: screenSize.width,
            AVVideoHeightKey: screenSize.height
            ] as [String : Any];
        self.assetWriterInput_ = AVAssetWriterInput.init(mediaType: AVMediaType.video, outputSettings: videoInputSettings);
        self.assetWriterInput_?.expectsMediaDataInRealTime = true;
        self.assetWriterInput_?.mediaTimeScale = 60;
        if (self.assetWriter?.canAdd(self.assetWriterInput_!))! {
            self.assetWriter?.add(self.assetWriterInput_!);
        } else {
            debugPrint("Cannot add video input");
            return;
        }
        
        // Enable mic if selected
        if (self.isMicEnabled) {
            debugPrint("Mic Enabled");
            let audioInputSettings = [AVFormatIDKey: 1633772320,
                                      AVNumberOfChannelsKey: 1,
                                      AVSampleRateKey: 44100.0,
                                      AVEncoderBitRateKey: 64000];
            self.assetWriterInputAudio = AVAssetWriterInput.init(mediaType: .audio, outputSettings: audioInputSettings);
            self.assetWriterInputAudio?.expectsMediaDataInRealTime = true;
            
            if (self.assetWriter?.canAdd(self.assetWriterInput_!))! {
                self.assetWriter?.add(self.assetWriterInputAudio!);
                RPScreenRecorder.shared().isMicrophoneEnabled = true;
            } else {
                debugPrint("Cannot add audio input");
                return;
            }
        }
        
        RPScreenRecorder.shared().startCapture(handler: { (sampleBuffer: CMSampleBuffer, bufferType: RPSampleBufferType, error: Error?) in
            if (error != nil) {
                debugPrint("Error in startCapture: ", error?.localizedDescription);
                return;
            }
            
            if (!CMSampleBufferDataIsReady(sampleBuffer)) {
                debugPrint("Not ready for writing...");
                return;
            }
            if (self.assetWriter?.status == AVAssetWriterStatus.failed) {
                debugPrint("Error handling writer: ", self.assetWriter?.error?.localizedDescription);
                return;
            }
            if (self.assetWriter?.status != AVAssetWriterStatus.writing) {
                debugPrint("Not writing...");
            }
            
            switch (bufferType) {
            case .video:
                if (!self.videoSessionStarted) {
                    debugPrint("Starting video session ...");
                    self.videoSessionStarted = true;
                    if (self.assetWriter?.status != AVAssetWriterStatus.writing) {
                        if (!(self.assetWriter?.startWriting())!) {
                            debugPrint("Writing error: ", self.assetWriter?.error?.localizedDescription);
                            return;
                        }
                    }
                    self.assetWriter?.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(sampleBuffer));
                    debugPrint("Writing successed.");
                }
                
                if (self.assetWriterInput_?.isReadyForMoreMediaData)! {
                    debugPrint("Adding buffer to video input ...");
                    self.assetWriterInput_?.append(sampleBuffer);
                }
                break;
            case .audioMic:
                do {
                    if (!self.audioSessionStarted) {
                        debugPrint("Starting audio session ...");
                        
                        if (self.assetWriter?.status != AVAssetWriterStatus.writing) {
                            if (!(self.assetWriter?.startWriting())!) {
                                debugPrint("Writing error: ", self.assetWriter?.error?.localizedDescription);
                                return;
                            }
                        }
                        try self.assetWriter?.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(sampleBuffer));
                        
                        self.audioSessionStarted = true;
                        debugPrint("Writing successed.");
                    }
                    if (self.assetWriterInputAudio?.isReadyForMoreMediaData)! {
                        self.assetWriterInputAudio?.append(sampleBuffer);
                    }
                } catch {
                    return;
                }
                break;
            default:
                break;
            }
            
        }, completionHandler: { (error: Error?) in
            if (error == nil) {
                return;
            }
            debugPrint("Error recording screen: ", error?.localizedDescription);
            return;
        });
        
    }
    
    func a() {
        self.screenRecorder = RPScreenRecorder.shared();
        if (self.screenRecorder?.isRecording)! {
            return;
        }
        
//        var error: Error? = nil;
        let pathDocuments: [String] = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true);
        let outputURL = pathDocuments [0];
        let videoOutPath = outputURL + "/temp.mp4";
        deleteFile(filePath: videoOutPath);
        
        debugPrint(videoOutPath);
        
        do {
            self.assetWriter = try AVAssetWriter.init(url: URL(fileURLWithPath: videoOutPath), fileType: .mp4);
        } catch {
            debugPrint("error catched.");
            return;
        }
        let compressionProperties = [AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel,
                                     AVVideoH264EntropyModeKey: AVVideoH264EntropyModeCABAC,
                                     AVVideoAverageBitRateKey: 1920 * 1080 * 11.4,
                                     AVVideoMaxKeyFrameIntervalKey: 60,
                                     AVVideoAllowFrameReorderingKey: false] as [String : Any];
        let width = self.view.frame.size.width;
        let height = self.view.frame.size.height;
        
        if #available(iOS 11.0, *) {
            let videoSettings = [AVVideoCompressionPropertiesKey: compressionProperties,
                                 AVVideoCodecKey: AVVideoCodecType.h264,
                                 AVVideoWidthKey: width,
                                 AVVideoHeightKey: height] as [String : Any];
            
            self.assetWriterInput_ = AVAssetWriterInput.init(mediaType: AVMediaType.video, outputSettings: videoSettings);
        } else {
            debugPrint("Fallback on earlier versions");
        }
        self.assetWriter?.add(self.assetWriterInput_!);
        self.assetWriterInput_?.mediaTimeScale = 60;
        self.assetWriter?.movieTimeScale = 60;
        self.assetWriterInput_?.expectsMediaDataInRealTime = true;
        
        if #available(iOS 11.0, *) {
            AVCaptureDevice.requestAccess(for: .video) { (granted: Bool) in
                DispatchQueue.main.async {
                    if (granted) {
                        self.screenRecorder?.isMicrophoneEnabled = true;
                        
                        self.screenRecorder?.startCapture(handler: { (sampleBuffer: CMSampleBuffer, bufferType: RPSampleBufferType, error: Error?) in
                            if (CMSampleBufferDataIsReady(sampleBuffer)) {
                                if (self.assetWriter?.status == AVAssetWriterStatus.unknown
                                    && bufferType == RPSampleBufferType.video) {
                                    self.assetWriter?.startWriting();
                                    self.assetWriter?.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(sampleBuffer));
                                }
                                if (self.assetWriter?.status == AVAssetWriterStatus.failed) {
                                    debugPrint("An error occured.");
                                    RPScreenRecorder.shared().stopCapture(handler: { (error: Error?) in });
                                    return;
                                }
                                if (bufferType == RPSampleBufferType.video) {
                                    if (self.assetWriterInput_?.isReadyForMoreMediaData)! {
                                        self.assetWriterInput_?.append(sampleBuffer);
                                    } else {
                                        debugPrint("Not ready for video");
                                    }
                                }
                            }
                        }, completionHandler: { (error: Error?) in
                            if (error == nil) {
                                let session: AVAudioSession = AVAudioSession.sharedInstance();
                                do {
                                    try session.setActive(true);
                                } catch {
                                    debugPrint("Recording started failed (do_catch).");
                                }
                                debugPrint("Recording started successfully.");
                            } else {
                                //show alert
                            }
                        });
                    }
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    @IBAction func onBtnStop(_ sender: Any) {
        RPScreenRecorder.shared().stopCapture { (error: Error?) in
            if (error == nil && self.assetWriter?.status != AVAssetWriterStatus.failed) {
                self.assetWriter?.finishWriting(completionHandler: {
                    debugPrint("Status: ", self.assetWriter?.status);
                    if (self.assetWriter?.status != AVAssetWriterStatus.completed) {
                        debugPrint("Error finishing writing ...");
                        return;
                    }
                    //let url = self.assetWriter?.outputURL.absoluteString;
                    
                    let player = AVPlayer(url: (self.assetWriter?.outputURL)!)
                    let playerViewController = AVPlayerViewController()
                    playerViewController.player = player
                    self.present(playerViewController, animated: true) {
                        playerViewController.player!.play()
                    }
                    
                    self.assetWriter = nil;
                })
            } else {
                debugPrint("Error stopping capture: ", error?.localizedDescription);
            }
        }
    }
    
    func b() {
        if #available(iOS 11.0, *) {
            DispatchQueue.main.async {
                RPScreenRecorder.shared().stopCapture(handler: { (error: Error?) in
                    if (error == nil) {
                        debugPrint("Recording stopped successfully. Cleaning up...");
                        self.assetWriterInput_?.markAsFinished();
                        self.assetWriter?.finishWriting(completionHandler: {
                            debugPrint("File Url: " + (self.assetWriter?.outputURL.absoluteString)!);
                            
                            let player = AVPlayer(url: (self.assetWriter?.outputURL)!)
                            let playerViewController = AVPlayerViewController()
                            playerViewController.player = player
                            self.present(playerViewController, animated: true) {
                                playerViewController.player!.play()
                            }
                            
                            self.assetWriterInput_ = nil;
                            self.assetWriter = nil;
                            self.screenRecorder = nil;
                        });
                    }
                });
            }
        } else {
            debugPrint("Fallback on earlier versions");
        }
    }
    
    
    func deleteFile(filePath: String) {
        let url = URL.init(fileURLWithPath: filePath);
        let fm = FileManager.default;
        let exist: Bool = fm.fileExists(atPath: url.path);
        if (exist) {
            do {
                try fm.removeItem(at: url);
                debugPrint("file delected");
            } catch let err {
                debugPrint("file remove error, ", err.localizedDescription);
                return;
            }
        } else {
            debugPrint("No file by that name");
        }
    }
    
}

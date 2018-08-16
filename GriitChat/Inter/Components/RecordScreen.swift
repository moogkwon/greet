//
//  RecordScreen.swift
//  ScreenRecTest
//
//  Created by GoldHorse on 7/21/18.
//  Copyright © 2018 GoldHorse. All rights reserved.
//

import UIKit

import ReplayKit
import AVKit
import CoreMedia

class RecordScreen: NSObject {
    
    var screenRecorder: RPScreenRecorder?;
    var assetWriter: AVAssetWriter?;
    var videoInput: AVAssetWriterInput?;
    var audioInput: AVAssetWriterInput?;
    
    var videoSessionStarted = false;
    var audioSessionStarted = false;
    var isMicEnabled = false;
    
    var isRecording = false;
    
    var isGetPermission = false;
    
    deinit {
        screenRecorder?.stopRecording(handler: nil);
        screenRecorder?.stopCapture(handler: nil);
        
        screenRecorder = nil;
        assetWriter = nil;
        videoInput = nil;
        audioInput = nil;
    }
    
    func getPermission(completion: ((_ result: Bool) -> Void)?) {
        if #available(iOS 11.0, *) {
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { (granted: Bool) in
                debugPrint("Video Capture Request: ", granted);
                
                if (!granted) {
                    completion!(false);
                    return;
                }
                AVCaptureDevice.requestAccess(for: AVMediaType.audio, completionHandler: { (granted: Bool) in
                    debugPrint("Audio Capture Request: ", granted);
                    
                    if (!granted) {
                        completion!(false);
                        return;
                    }
                    
                    if (!RPScreenRecorder.shared().isAvailable) {
                        completion!(false);
                        return;
                    }
                    
                    
                    var isReturned = false;
                    DispatchQueue.main.async {
                        
                        RPScreenRecorder.shared().isMicrophoneEnabled = true;
                        RPScreenRecorder.shared().startCapture(handler: { (sample: CMSampleBuffer, bufferType: RPSampleBufferType, error: Error?) in
                            
                            if (isReturned) { return }
                            isReturned = true;
                            
                            self.isMicEnabled = granted;
                            self.isGetPermission = true;
                            completion!(true);
                        });
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        RPScreenRecorder.shared().stopCapture { (error: Error?) in
                        };
                    })
                    
                })
            }
        } else {
            completion!(false);
            return;
        }
    }
    
    func startRecording(onStart: @escaping (_ result: Bool, _ error: String?) -> Void) {
        if (isRecording) { return }
        
        RPScreenRecorder.shared().isMicrophoneEnabled = true;
        
        self.isMicEnabled = true;
        self.isGetPermission = true;
        
        // Prepare asset writer
        let pathDocuments: [String] = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true);
        let outputURL = pathDocuments [0];
//        let videoOutPath = outputURL + "/temp1.mp4";
        let videoOutPath = FileManager.makeTempPath("mov");
        FileManager.deleteFile(filePath: videoOutPath);
        let fileURL = URL.init(fileURLWithPath: videoOutPath);
        let screenSize = UIScreen.main.bounds.size;
        
        debugPrint("Recording video to " + videoOutPath);
        do {
            self.assetWriter = try AVAssetWriter(url: fileURL, fileType: .mp4);
        } catch {
            onStart(false, "Asset Writer init error");
            return;
        }
        self.assetWriter?.movieTimeScale = 60;
        
        
        // Video input
        let videoInputSettings = [
            AVVideoCompressionPropertiesKey: [
                AVVideoPixelAspectRatioKey: [
                    AVVideoPixelAspectRatioVerticalSpacingKey: 1,
                    AVVideoPixelAspectRatioHorizontalSpacingKey: 1],
                AVVideoCleanApertureKey: [
                    AVVideoCleanApertureWidthKey: screenSize.width,
                    AVVideoCleanApertureHeightKey: screenSize.height,
                    AVVideoCleanApertureVerticalOffsetKey: 10,
                    AVVideoCleanApertureHorizontalOffsetKey: 10]],
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: screenSize.width,
            AVVideoHeightKey: screenSize.height
            ] as [String : Any];
        self.videoInput = AVAssetWriterInput.init(mediaType: AVMediaType.video, outputSettings: videoInputSettings);
        self.videoInput?.expectsMediaDataInRealTime = true;
        self.videoInput?.mediaTimeScale = 60;
        if (self.assetWriter?.canAdd(self.videoInput!))! {
            self.assetWriter?.add(self.videoInput!);
        } else {
            onStart(false, "Cannot add video input");
            return;
        }
        
        // Enable mic if selected
        if (self.isMicEnabled) {
            debugPrint("Mic Enabled");
            let audioInputSettings = [AVFormatIDKey: 1633772320,
                                      AVNumberOfChannelsKey: 1,
                                      AVSampleRateKey: 44100.0,
                                      AVEncoderBitRateKey: 64000];
            
            self.audioInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioInputSettings);
            self.audioInput?.expectsMediaDataInRealTime = true;
            
            if (self.assetWriter?.canAdd(self.videoInput!))! {
                self.assetWriter?.add(self.audioInput!);
                RPScreenRecorder.shared().isMicrophoneEnabled = true;
            } else {
                onStart(false, "Cannot add audio input");
                return;
            }
        }
        RPScreenRecorder.shared().startCapture(handler: { (sample: CMSampleBuffer, bufferType: RPSampleBufferType, error: Error?) in
            if (error != nil) {
                onStart(false, "Error in startCapture: " + (error?.localizedDescription)!);
                return;
            }
            
            if (!CMSampleBufferDataIsReady(sample)) {
                onStart(false, "Not ready for writing...");
                return;
            }
            
            if (self.assetWriter?.status == AVAssetWriterStatus.failed) {
                onStart(false, "Error handling writer: " +  (self.assetWriter?.error?.localizedDescription)!);
                return;
            }
            
            if (self.assetWriter?.status != AVAssetWriterStatus.writing) {
                debugPrint("Not writing... status = ", self.assetWriter?.status);
            }
            
            switch (bufferType) {
            case .video:
                if (!self.videoSessionStarted) {
                    debugPrint("Starting video session ...");
                    //                    if (self.assetWriter?.status != AVAssetWriterStatus.writing) {
                    if (!(self.assetWriter?.startWriting())!) {
                        onStart(false, "Writing error: " +  (self.assetWriter?.error?.localizedDescription)!);
                        return;
                    }
                    //                    }
                    self.videoSessionStarted = true;
                    self.assetWriter?.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(sample));
                    debugPrint("Writing successed.");
                }
                
                if (self.videoInput?.isReadyForMoreMediaData)! {
                    self.videoInput?.append(sample);
                    
                    self.isRecording = true;
                    onStart(true, "Recorder Start!!");
                }
                break;
            case .audioMic:
                if (!self.videoSessionStarted) {
                    break;
                }
                if (!self.isMicEnabled) {
                    debugPrint("Received audio buffer, but mic not enabled. Skipping ...");
                    break;
                }
                do {
                    if (!self.audioSessionStarted) {
                        debugPrint("Starting audio session ...");
                        
                        /*if (self.assetWriter?.status != AVAssetWriterStatus.writing) {
                         if (!(self.assetWriter?.startWriting())!) {
                         onStart(false, "Writing error: " +  (self.assetWriter?.error?.localizedDescription)!);
                         return;
                         }
                         }*/
                        self.audioSessionStarted = true;
                        try self.assetWriter?.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(sample));
                        
                        debugPrint("Writing successed.");
                    }
                    if (self.audioInput?.isReadyForMoreMediaData)! {
                        self.audioInput?.append(sample);
                    }
                } catch let e {
                    onStart(false, "Exception crashed : " + e.localizedDescription);
                    return;
                }
                break;
            default:
                break;
            }
            
        }, completionHandler: { (error: Error?) in
            if (error == nil) {
                onStart(true, nil);
                return;
            }
            onStart(false, "Error recording screen: " + (error?.localizedDescription)!);
            return;
        });
    }
    
    func stopRecord(completion: @escaping (_ result: Bool, _ url: URL?) -> Void) {
        isRecording = false;
        
        RPScreenRecorder.shared().stopCapture { (error: Error?) in
            if (error == nil
                && self.assetWriter?.status != AVAssetWriterStatus.failed
                && self.assetWriter?.status != .unknown) {
                
                self.assetWriter?.finishWriting(completionHandler: {
                    debugPrint("Status: ", self.assetWriter?.status);
                    if (self.assetWriter?.status != AVAssetWriterStatus.completed) {
                        debugPrint("Error finishing writing ...");
                        completion(false, self.assetWriter?.outputURL);
                        //                        self.releaseVars();
                        return;
                    }
                    //let url = self.assetWriter?.outputURL.absoluteString;
                    
                    completion(true, self.assetWriter?.outputURL);
                    //                    self.releaseVars();
                })
            } else {
                debugPrint("Error stopping capture: ", self.assetWriter?.status);
                completion(false, nil);
                //                self.releaseVars();
            }
        }
    }
}

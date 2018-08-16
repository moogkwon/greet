//
//  CameraView.swift
//  CamTest
//
//  Created by GoldHorse on 7/16/18.
//  Copyright © 2018 GoldHorse. All rights reserved.
//

import UIKit
import AVFoundation

class CameraView: GradientView, AVCaptureVideoDataOutputSampleBufferDelegate {

    //Camera Capture requiered properties
    var videoDataOutput: AVCaptureVideoDataOutput!
    var videoDataOutputQueue: DispatchQueue!
    var previewLayer:AVCaptureVideoPreviewLayer!
    var captureDevice : AVCaptureDevice!
    let session = AVCaptureSession()
    
    var isCreatedCamera = false;
    
    deinit {
        stopCamera();
    }
    
    func setupAVCapture() -> Bool {
        if (isCreatedCamera) {
            return false;
        }
        debugPrint("Camera Start!!");
        isCreatedCamera = true;
        
        session.sessionPreset = .high;
        //        session.sessionPreset = AVCaptureSession.Preset.vga640x480
        guard let device = AVCaptureDevice
            .default(AVCaptureDevice.DeviceType.builtInWideAngleCamera,
                     for: .video,
                     position: .front) else {
//                        backgroundColor = UIColor.lightGray;
                        return false;
        }
        captureDevice = device
        beginSession()
        return true;
    }
    
    func beginSession() {
        var deviceInput: AVCaptureDeviceInput!
        
        do {
            deviceInput = try AVCaptureDeviceInput(device: captureDevice)
            guard deviceInput != nil else {
                backgroundColor = UIColor.red;
                print("error: cant get deviceInput")
                return
            }
            
            if self.session.canAddInput(deviceInput){
                self.session.addInput(deviceInput)
            }
            
            videoDataOutput = AVCaptureVideoDataOutput()
            videoDataOutput.alwaysDiscardsLateVideoFrames=true
            videoDataOutputQueue = DispatchQueue(label: "VideoDataOutputQueue")
            videoDataOutput.setSampleBufferDelegate(self, queue:self.videoDataOutputQueue)
            
            if session.canAddOutput(self.videoDataOutput){
                session.addOutput(self.videoDataOutput)
            }
            
            videoDataOutput.connection(with: .video)?.isEnabled = true
            
            previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
            previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            
            let rootLayer :CALayer = self.layer
            rootLayer.masksToBounds=true
            previewLayer.frame = rootLayer.bounds

            rootLayer.addSublayer(self.previewLayer)
            session.startRunning()
            /*
            DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                UIGraphicsBeginImageContext(self.previewLayer.frame.size);
                
                self.layer.render(in: UIGraphicsGetCurrentContext()!);
                let outputImage = UIGraphicsGetImageFromCurrentImageContext();
                
                UIGraphicsEndImageContext();
            })*/
        } catch let error as NSError {
            deviceInput = nil
            print("error: \(error.localizedDescription)")
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // do stuff here
    }
    
    // clean up AVCapture
    func stopCamera() {
        if (isCreatedCamera) {
            debugPrint("Camera Stop!!");
            session.stopRunning()
            isCreatedCamera = false;
        }
    }
}

//
//  UploadVideoTemplateViewController.swift
//  GriitChat
//
//  Created by GoldHorse on 8/4/18.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class UploadVideoTemplateViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, TransMngUploadVideoDelegate {

    var imagePickerController: UIImagePickerController? = nil;
    
    var targetVideoPath: String? = nil;
    
    var assetWriter:AVAssetWriter?
    var assetReader:AVAssetReader?
    let bitrate:NSNumber = NSNumber(value: 250000)
        //250000    1.3MB
        //125000    0.65MB
        //62500     0.69
    
        //250000    size/2      0.48MB
        //200000    size/2      0.43MB
    
        //200000    size/2.5    0.43MB
    
        //200000    size/3      0.44MB
    
        //125000    size/3      0.36MB
    
        //200000    size/4      0.43MB
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if (info [UIImagePickerControllerMediaType] as! String == "public.image") {
            //Image
            if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                
                var croppedImage = info [UIImagePickerControllerEditedImage] as? UIImage;
                
                if (croppedImage?.size.width != croppedImage?.size.height) {
                    var size = croppedImage?.size.width;
                    if (Double((croppedImage?.size.width)!) > Double((croppedImage?.size.height)!)) {
                        size = croppedImage?.size.height;
                    }
                    
                    croppedImage = UIImage.cropToBounds(image: croppedImage!,
                                                        width: Double(size!), height: Double(size!));
                }
                
                let newSmallImg = croppedImage?.resizeImage(newWidth: 200);
                
                let imgPath = FileManager.makeTempPath("jpg");
                croppedImage?.saveImage(savePath: imgPath);
                Extern.transMng.userInfo? ["photoUrl"] = URL(fileURLWithPath: imgPath).absoluteString;
                
                let imageData:NSData = UIImageJPEGRepresentation(newSmallImg!, 0.4) as! NSData;
                
                var strBase64 = imageData.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
                
                dismiss(animated: true, completion: nil);
                _ = Extern.transMng.sendMessage(msg: ["id" : "uploadPhoto",
                                                      "data": strBase64]);
                strBase64.removeAll();
                croppedImage = nil;
                
                Extern.mainVC?.momentMainPage.settingPage?.setProfilePhoto();
            }
        } else if (info [UIImagePickerControllerMediaType] as! String == "public.movie") {
            let url = info [UIImagePickerControllerMediaURL] as? URL;
//            compressVideo(videoUrl: url!);
            
            targetVideoPath = FileManager.makeTempPath("mov");
            compressFile(urlToCompress: url!, outputURL: URL(fileURLWithPath: self.targetVideoPath!)) { (url: URL) in
                
                self.uploadVideo(path: url.path);
                /*self.dismiss(animated: true, completion: {
                    let player = AVPlayer(url: url)
                    let playerController = AVPlayerViewController()
                    playerController.player = player
                    self.present(playerController, animated: true) {
                        player.play()
                    }
                })*/
            }
        }
    }
    
    func compressFile(urlToCompress: URL, outputURL: URL, completion:@escaping (URL)->Void){
        //video file to make the asset
        var audioFinished = false
        var videoFinished = false
        
        let asset = AVAsset(url: urlToCompress);
        
        //create asset reader
        do{
            assetReader = try AVAssetReader(asset: asset)
        } catch{
            assetReader = nil
        }
        
        guard let reader = assetReader else{
            fatalError("Could not initalize asset reader probably failed its try catch")
        }
        
        let videoTrack = asset.tracks(withMediaType: AVMediaType.video).first!
        let audioTrack = asset.tracks(withMediaType: AVMediaType.audio).first!
        
        let videoReaderSettings: [String:Any] =  [kCVPixelBufferPixelFormatTypeKey as String!:kCVPixelFormatType_32ARGB ]
        
        // ADJUST BIT RATE OF VIDEO HERE
        
        let targetWidth: CGFloat = 330;
        
        let divRatio: CGFloat = CGFloat(floor(Float(videoTrack.naturalSize.width / targetWidth))) + 1;
        
        let videoSettings:[String:Any] = [
            AVVideoCompressionPropertiesKey: [AVVideoAverageBitRateKey:self.bitrate],
            AVVideoCodecKey: AVVideoCodecH264,
            AVVideoHeightKey: videoTrack.naturalSize.height / divRatio,
            AVVideoWidthKey: videoTrack.naturalSize.width / divRatio
        ]
        
        
        let assetReaderVideoOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: videoReaderSettings)
        let assetReaderAudioOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: nil)
        
        
        if reader.canAdd(assetReaderVideoOutput){
            reader.add(assetReaderVideoOutput)
        }else{
            fatalError("Couldn't add video output reader")
        }
        
        if reader.canAdd(assetReaderAudioOutput){
            reader.add(assetReaderAudioOutput)
        }else{
            fatalError("Couldn't add audio output reader")
        }
        
        let audioInput = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: nil)
        let videoInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoSettings)
        videoInput.transform = videoTrack.preferredTransform
        //we need to add samples to the video input
        
        let videoInputQueue = DispatchQueue(label: "videoQueue")
        let audioInputQueue = DispatchQueue(label: "audioQueue")
        
        do{
            assetWriter = try AVAssetWriter(outputURL: outputURL, fileType: AVFileType.mov)
        }catch{
            assetWriter = nil
        }
        guard let writer = assetWriter else{
            fatalError("assetWriter was nil")
        }
        
        writer.shouldOptimizeForNetworkUse = true
        writer.add(videoInput)
        writer.add(audioInput)
        
        
        writer.startWriting()
        reader.startReading()
        writer.startSession(atSourceTime: kCMTimeZero)
        
        
        let closeWriter:()->Void = {
            if (audioFinished && videoFinished){
                self.assetWriter?.finishWriting(completionHandler: {
                    
                    self.checkFileSize(sizeUrl: (self.assetWriter?.outputURL)!, message: "The file size of the compressed file is: ")
                    
                    completion((self.assetWriter?.outputURL)!)
                    
                })
                
                self.assetReader?.cancelReading()
                
            }
        }
        
        
        audioInput.requestMediaDataWhenReady(on: audioInputQueue) {
            while(audioInput.isReadyForMoreMediaData){
                let sample = assetReaderAudioOutput.copyNextSampleBuffer()
                if (sample != nil){
                    audioInput.append(sample!)
                }else{
                    audioInput.markAsFinished()
                    DispatchQueue.main.async {
                        audioFinished = true
                        closeWriter()
                    }
                    break;
                }
            }
        }
        
        videoInput.requestMediaDataWhenReady(on: videoInputQueue) {
            //request data here
            
            while(videoInput.isReadyForMoreMediaData){
                let sample = assetReaderVideoOutput.copyNextSampleBuffer()
                if (sample != nil){
                    videoInput.append(sample!)
                }else{
                    videoInput.markAsFinished()
                    DispatchQueue.main.async {
                        videoFinished = true
                        closeWriter()
                    }
                    break;
                }
            }
        }
    }
    
    func checkFileSize(sizeUrl: URL, message:String){
        let data = NSData(contentsOf: sizeUrl)!
        print(message, (Double(data.length) / 1048576.0), " mb")
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
            
            Extern.transMng.uploadVideoDelegate = self;
            let result = Extern.transMng.uploadVideo(videoData: base64Data);
            base64Data.removeAll();
            stream.close();
            
            if (!result) {
                imagePickerController?.showNetworkErrorMessage(completion: {
                    self.dismiss(animated: true, completion: nil);
                })
            }
        } else {
            imagePickerController?.showMessage(title: "Error", content: "Input Stream Error.", completion: {
                self.dismiss(animated: true, completion: nil);
            })
        }
    }
    
    func onUploadVideo(result: Bool, message: Dictionary<String, Any>?) {
        if (result) {
            //Success...
            //Remove old file.
            /*if (UserDefaults.standard.string(forKey: UserKey.Profile_Shared_Key) != nil) {
                let videoPath = UserDefaults.standard.string(forKey: UserKey.Profile_Shared_Key);
                FileManager.deleteFile(filePath: videoPath!);
            }
            
            //Save new video file path.
            UserDefaults.standard.set(targetVideoPath, forKey: UserKey.Profile_Shared_Key);*/
            let videoPath: String = message? ["videoPath"] as! String;
            Extern.transMng.userInfo? ["videoPath"] = videoPath;
        } else {
            let strMsg: String? = message! ["message"] as? String;
            imagePickerController?.showMessage(title: "Upload Video Error", content: strMsg!, completion: {
                self.dismiss(animated: true, completion: nil);
            })
        }
    }
}

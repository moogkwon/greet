//
//  VideoViewController.swift
//  GriitChat
//
//  Created by leo on 11/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit
import AVKit
import MobileCoreServices
import AVKit

class VideoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var accessgif: UIImageView!
    
    
    @IBOutlet weak var uploadgif: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        accessgif.loadGif(asset: "accessgif");
        uploadgif.loadGif(asset: "uploadgif");
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

    @IBAction func onShowMoment(_ sender: Any) {
        VideoHelper.startMediaBrowser(delegate: self, sourceType: .savedPhotosAlbum)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {        
        let videoVC = self.storyboard?.instantiateViewController(withIdentifier: "VideoTrimViewController") as! VideoTrimViewController;
        videoVC.videoUrl = info[UIImagePickerControllerMediaURL] as? URL;
        
        dismiss(animated: true) {
            self.navigationController?.pushViewController(videoVC, animated: true);
        }
    }
    
    
    var glimpse: Glimpse?;
    
    var isRecording: Bool = false;
    @IBAction func onBtnRecord(_ sender: Any) {
        isRecording = true;
        glimpse = Glimpse.init();
        glimpse?.startRecording(self.view, withCallback: recordComplete);
    }
    
    func recordComplete(outputUrl: URL?) {
        let player = AVPlayer(url: outputUrl!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    
    @IBAction func onBtnStop_Play(_ sender: Any) {
        if (!isRecording) {
            return;
        }
        glimpse?.stop();
        isRecording = false;
    }
    
}

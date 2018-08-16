//
//  UploadVideoViewController.swift
//  GriitChat
//
//  Created by leo on 14/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit

class UploadVideoViewController: UploadVideoTemplateViewController {
    
    @IBOutlet weak var imgGif: UIImageView!
    
    @IBOutlet weak var btnUploadVideo: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let backView: GradientView = super.view as! GradientView;
        backView.setBackColors(colors: [UIColor.dodgerBlue.cgColor, UIColor.brightLightBlue.cgColor]);
        
        imgGif.loadGif(asset: "uploadgif");
        
        imgGif.layer.cornerRadius = 20;
        imgGif.clipsToBounds = true;
        
        btnUploadVideo.clipsToBounds = true;
        
        navigationController?.navigationBar.isHidden = true;
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.setNavigationBarHidden(true, animated: true);
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews();
        
        btnUploadVideo.layer.cornerRadius = btnUploadVideo.frame.height / 2;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onBtnUpload(_ sender: Any) {
        imagePickerController = VideoHelper.startMediaBrowser(delegate: self, sourceType: .savedPhotosAlbum)
    }
    
    override func onUploadVideo(result: Bool, message: Dictionary<String, Any>?) {
        super.onUploadVideo(result: result, message: message);
        
        if (result) {
            let nextVC: UIViewController!;
//            if (UserDefaults.standard.object(forKey: UserKey.IsAllowDevice) == nil) {
                nextVC = self.storyboard?.instantiateViewController(withIdentifier: "AllowDeviceViewController");
/*            } else {
                nextVC = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController");
            }*/
            
            dismiss(animated: true) {
                self.navigationController?.setNavigationBarHidden(true, animated: true);
                self.navigationController?.pushViewController(nextVC, animated: true);
                self.imgGif.remove();
            }
        }
    }
}

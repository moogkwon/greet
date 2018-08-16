//
//  RandomViewController.swift
//  GriitChat
//
//  Created by leo on 18/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit

class RandomViewController: CalleeViewController/*, CalleeReceiveCallDelegate*/ {

    @IBOutlet var profileViewer: ProfileViewer!
    
    @IBOutlet weak var imgPhoto: UIImageView!
    
    @IBOutlet weak var lblUserName: UILabel!
    
    @IBOutlet weak var lblUserLocation: UILabel!
    
    var userInfo: Dictionary<String, Any>? = nil;
    
    var parentController: RandomMainViewController!;
    
    var isCaller: ChatCoreViewController.UserType!;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setGradientBack(view: self.view);
        
        imgPhoto.layer.cornerRadius = imgPhoto.bounds.width / 2;
        imgPhoto.clipsToBounds = true;
        imgPhoto.layer.borderColor = UIColor.red.cgColor;
        imgPhoto.layer.borderWidth = 1;
        
        isCaller = Extern.chat_userType;
        userInfo = Extern.chat_userInfo;
        
        if (userInfo! ["photo"] as! String == "") {
            imgPhoto.image = UIImage(named: Assets.Default_User_Image);
        } else {
            imgPhoto.image = UIImage.base64_2Image(base64Str: userInfo! ["photo"] as! String)
        }
        
        lblUserName.text = userInfo? ["firstName"] as? String;
        
        let phoneNumber: String = userInfo? ["phoneNumber"] as! String;
        
        let indexStartOfText: String.Index = phoneNumber.index(phoneNumber.startIndex, offsetBy: phoneNumber.count - 10)
        let phoneExt = String(phoneNumber[..<indexStartOfText]);
        
        let country: Country = Country(countryCode: userInfo? ["country_code"] as! String, phoneExtension: phoneExt);
        lblUserLocation.text = (userInfo? ["location"] as! String) + "  " + country.flag!
        
        if (isCaller == .Caller) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.startChatting();
            }
        }
    }
    
    deinit {
        userInfo = nil;
        
        parentController = nil;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        
        Extern.transMng.userStatus = .WaitingCall;
        
        profileViewer.createProfileViewer(videoPath: Extern.chat_videoPath);
    }
    
    func startChatting() {
        Extern.transMng.userStatus = .ReadyCall;
        
        RandomMainViewController.showMainRandom(view: view, navState: .Init_Chat_Loading, isAnimation: true);
    }
    
    override func onIncomingCall(message: Dictionary<String, Any>) {
        RandomMainViewController.showMainRandom(view: view, navState: .Init_Chat_Loading, isAnimation: true);
        
        /*let chatVC = self.storyboard?.instantiateViewController(withIdentifier: "EngineChatViewController") as! EngineChatViewController;
        chatVC.transMng = self.transMng;
        
        chatVC.fromId = message ["from"] as! String;
        chatVC.toId = (self.transMng?.phoneNumber)!;
        chatVC.userType = EngineChatViewController.UserType.Callee;
        self.navigationController?.pushViewController(chatVC, animated: true);*/
    }
}

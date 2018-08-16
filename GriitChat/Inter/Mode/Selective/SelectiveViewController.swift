//
//  SelectiveViewController.swift
//  GriitChat
//
//  Created by leo on 15/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit

class SelectiveViewController: CalleeViewController, UIActionSheetDelegate, TransMngCallingDelegate {
    
//    var parent: SelectiveMainViewController!;
    
    @IBOutlet var profileViewer: ProfileViewer!
    
    @IBOutlet weak var imgPhoto: UIImageView!
    
    @IBOutlet weak var lblUserName: UILabel!
    
    @IBOutlet weak var lblUserLocation: UILabel!
    
    @IBOutlet weak var skinCallingView: LoadingView!

    @IBOutlet weak var camView: CameraView!
    
    var videoPath: String = "";
    var userInfo: Dictionary<String, Any>? = nil;
    
    @IBOutlet weak var viewSwipe: UIView!
    
    var parentController: SelectiveMainViewController!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgPhoto.layer.cornerRadius = imgPhoto.bounds.width / 2;
        imgPhoto.clipsToBounds = true;
        imgPhoto.layer.borderColor = UIColor.red.cgColor;
        imgPhoto.layer.borderWidth = 1;
        
        userInfo = Extern.chat_userInfo;
        videoPath = Extern.chat_videoPath
        
        if (userInfo! ["photo"] as! String == "") {
            imgPhoto.image = UIImage(named: Assets.Default_User_Image);
        } else {
            imgPhoto.image = UIImage.base64_2Image(base64Str: userInfo! ["photo"] as! String)
        }
        
        createGesture();
        
        lblUserName.text = userInfo? ["firstName"] as? String;
        
        let phoneNumber: String = userInfo? ["phoneNumber"] as! String;
        
        let indexStartOfText: String.Index = phoneNumber.index(phoneNumber.startIndex, offsetBy: phoneNumber.count - 10)
        let phoneExt = String(phoneNumber[..<indexStartOfText]);
        
        let country: Country = Country(countryCode: userInfo? ["country_code"] as! String, phoneExtension: phoneExt);
        lblUserLocation.text = (userInfo? ["location"] as! String) + "  " + country.flag!
        
        createCallingView();
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            let img: UIImage = Extern.takeScreenshot()!;
            let imgPath = FileManager.makeTempPath("png");
            _ = img.saveImage(savePath: imgPath);
            
            Extern.dbMoments.addItem(phoneNumber: self.userInfo! ["phoneNumber"] as! String, photoPath: imgPath, videoPath: self.videoPath);
        }
    }
    
    deinit {
        userInfo = nil;
        
        parentController = nil;
    }
  
    func freeClass() {
        if (profileViewer != nil) {
            profileViewer.removeFromSuperview();
//            profileViewer.freeClass();
            profileViewer = nil;
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
//        sToolbarView.setActive(tabName: .Selective);

        profileViewer.createProfileViewer(videoPath: videoPath);
        
        skinCallingView.addSubview(camView);
    }
    
    func createGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tap.numberOfTapsRequired = 2
        self.viewSwipe.addGestureRecognizer(tap)
        
        self.viewSwipe.isUserInteractionEnabled = true
        self.viewSwipe.isMultipleTouchEnabled = true
        
        self.viewSwipe.backgroundColor = UIColor.clear;
    }
    
    func createCallingView() {
        skinCallingView.setGradBackAlpha(alpha: 0.8);
        skinCallingView.setProgMaxValue(maxValue: CGFloat(TransMng.COUNT_RINGTONE - 1));
        skinCallingView.showLabel(number: TransMng.COUNT_RINGTONE);
        
        camView.backgroundColor = nil;
        camView.layer.cornerRadius = 10;
        camView.clipsToBounds = true;
        
        skinCallingView.isHidden = true;
    }
    
    @objc func doubleTapped(gesture: UISwipeGestureRecognizer) -> Void {
        visibleCallingView(isVisible: true);
        self.startCall();
        
        skinCallingView.setProgValue(value: 0, duration: 0);
    }
    
    @IBAction func onBtnReport(_ sender: Any) {
        let title = "Would you like to report this user?";
        let message = "Our goal is to create a respectful community.\nWe review the reports very seriously.\nPlease don’t hesitate to report inappropriate behaviors. We will take care of the situation 👮‍♂️";
        
        let actionCont = UIAlertController(title: title, message: message, preferredStyle: .actionSheet);
        
        let action1 = UIAlertAction(title: "Person is nude 🔞", style: .default, handler: onReport)
        let action2 = UIAlertAction(title: "Inappropriate video profile 🙈", style: .default, handler: onReport)
        let action3 = UIAlertAction(title: "There's other reason 🤐", style: .default, handler: onReport)
        let action4 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionCont.addAction(action1);
        actionCont.addAction(action2);
        actionCont.addAction(action3);
        actionCont.addAction(action4);
        
        present(actionCont, animated: true, completion: nil);
    }
    
    func onReport(action: UIAlertAction) {
        let id = userInfo! ["id"] as! Int;
        Extern.transMng.reportUser(id: id, report: action.title!);
    }
    
    //isVisible : false     Show => hide
    //          : true      hide => show
    func visibleCallingView(isVisible: Bool) {
        skinCallingView.alpha = isVisible ? 0 : 1;
        skinCallingView.isHidden = false;
        if (isVisible) {
            _ = camView.setupAVCapture();
            parentController.allowToMove(isAllow: false);
        } else {
            camView.stopCamera();
            parentController.allowToMove(isAllow: true);
        }
        
        UIView.animate(withDuration: 0.5, animations: {
            self.skinCallingView.alpha = isVisible ? 1 : 0;
            self.skinCallingView.isHidden = !isVisible;
        }, completion: {finished in
        })
    }
    
    func startCall() {
        Extern.transMng.callingDelegate = self;
        _ = Extern.transMng.call(phoneNumber: userInfo! ["phoneNumber"] as! String);
    }
    
    //Caller => Server => Caller
    func onCallingResponse(data: Dictionary<String, Any>) {
        if (data ["callee"] == nil) {
            //If error comes from server...
            let alert = UIAlertController(title: "Calling Result", message: data ["message"] as? String, preferredStyle: UIAlertControllerStyle.alert)

            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_:UIAlertAction) -> Void in
                self.visibleCallingView(isVisible: false);
            }));
            self.present(alert, animated: true, completion: nil)
            return;
        }
        let result: Int = data ["result"] as! Int;
        let callee: String = data ["callee"] as! String;
        let remainSec: Int = data ["remainSec"] as! Int;
        
        if (callee != userInfo! ["phoneNumber"] as! String) {
            return;
        }
        
        if (result == -1) {
            //Refuse call in callee.
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Calling Result", message: data ["message"] as? String, preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_:UIAlertAction) -> Void in
                    self.visibleCallingView(isVisible: false);
                }));
                self.present(alert, animated: true, completion: nil)
            }
            Extern.transMng.userStatus = .Logined;
        } else if (result == 0) {
            if (remainSec == 0) {
                //Timeout...
                DispatchQueue.main.async {
                    self.visibleCallingView(isVisible: false);
                }
                Extern.transMng.userStatus = .Logined;
            } else {
                //Showing seconds.
                DispatchQueue.main.async {
                    let showProg: CGFloat = CGFloat(TransMng.COUNT_RINGTONE - remainSec);
                    
                    self.skinCallingView.showLabel(number: remainSec - 1);
                    self.skinCallingView.setProgValue(value: showProg, duration: 1.1);
                }
            }
        } else if (result == 1) {
            ////////////////////////////
            /*DispatchQueue.main.async {
                self.showMessage(title: "AAAA", content: "calling response success.");
            }
            debugPrint("Here is Call!!!");*/
            
            Extern.transMng.userStatus = .ReadyCall;
            Extern.chat_userType = .Caller;
            
            SelectiveMainViewController.showMainSelective(view: view, navState: .Chat_Loading, isAnimation: true);
            
            ////////////////////////////
            
            /*let chatVC = self.storyboard?.instantiateViewController(withIdentifier: "EngineChatViewController") as! EngineChatViewController;
            transMng?.userStatus = .ReadyCall;
            chatVC.transMng = self.transMng;
            chatVC.toId = callee;
            chatVC.fromId = (self.transMng?.phoneNumber)!;
            chatVC.userType = EngineChatViewController.UserType.Caller;
            
            var VCs = self.navigationController?.viewControllers;
            VCs! [((VCs?.count)! - 1)] = chatVC;
            self.navigationController?.setViewControllers(VCs!, animated: true);*/
        }
    }
    
    override func onIncomingCall(message: Dictionary<String, Any>) {
        Extern.chat_userInfo = userInfo;
        Extern.chat_userType = .Callee;
        
        SelectiveMainViewController.showMainSelective(view: view, navState: .Chat_Loading, isAnimation: true);
    }
}

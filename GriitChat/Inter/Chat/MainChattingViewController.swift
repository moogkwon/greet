//
//  EngineChatViewController.swift
//  GriitChat
//
//  Created by leo on 07/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit

class MainChattingViewController: ChatCoreViewController, InstagramBtnDelegate {
    
    @IBOutlet weak var viewLocalContainer: GradientView!
    
    @IBOutlet weak var viewRemoteContainer: GradientView!
    
    @IBOutlet weak var btnToggle: UIButton!
    
    @IBOutlet weak var btnAddUser: UIButton!
    
    @IBOutlet weak var btnInstagram: InstagramButton!
    
    @IBOutlet weak var btnReport: UIButton!
    
    @IBOutlet weak var btnSecond: UIButton!
    
    @IBOutlet weak var viewFriendBox: UIView!
    
    @IBOutlet weak var lblFriendName: UILabel!
    
    @IBOutlet weak var notifyFriend: NotifyView!
    
    @IBOutlet weak var notifyInstagram: NotifyView!
    
    var isLocalSmall = true;
    
    var localFrame: CGRect!;
    
    var parentController: SwipeViewController!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewLocalContainer.setBackColors(colors: [UIColor.dodgerBlue.cgColor, UIColor.brightLightBlue.cgColor]);
        viewRemoteContainer.setBackColors(colors: [UIColor.dodgerBlue.cgColor, UIColor.brightLightBlue.cgColor]);
        
        setBorder(view: viewLocalContainer);
        
        btnInstagram.backgroundColor = UIColor.clear;
        btnInstagram.layer.borderWidth = 2;
        btnInstagram.layer.borderColor = UIColor.white.cgColor;
        btnInstagram.clipsToBounds = true;
        
        btnSecond.applyGradient(colours: [UIColor.dodgerBlue.cgColor, UIColor.brightLightBlue.cgColor], direction: UIView.GradientDirection.vertical, frame: btnSecond.bounds)
        btnSecond.clipsToBounds = true;
        
        lblFriendName.text = "TEST NAME";   //Extern.chat_userInfo ["instagramName"] as? String;
        
        btnInstagram.setBtnState(state: .Disabled);
        btnInstagram.delegate = self;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        let frame = view.frame;
        
        localFrame = CGRect(x: 0.059 * frame.width, y: 0.075 * frame.height, width: 0.248 * frame.width, height: 0.191 * frame.height);
        
        if (self.isLocalSmall) {
            viewRemoteContainer.frame = frame;
            viewLocalContainer.frame = localFrame;
        } else {
            viewRemoteContainer.frame = localFrame;
            viewLocalContainer.frame = frame;
        }
        
        btnToggle.frame = localFrame;
        
        btnToggle.backgroundColor = UIColor.clear;
        
        btnInstagram.layer.cornerRadius = btnInstagram.bounds.width / 2
        btnSecond.layer.cornerRadius = btnSecond.bounds.width / 2
        
        setFriendGradient();
    }
    
    func setFriendGradient() {
        if (Extern.transMng.userInfo! ["lgbtq"] as! Int == 1
            && Extern.chat_userInfo ["lgbtq"] as! Int == 1) {
        
            viewFriendBox.applyGradient(
                colours: [UIColor(red: 178.0 / 255.0, green: 16.0 / 255.0, blue: 227.0 / 255.0, alpha: 1).cgColor,
                          UIColor(red: 83.0 / 255.0, green: 125.0 / 255.0, blue: 253.0 / 255.0, alpha: 1).cgColor,
                          UIColor(red: 70.0 / 255.0, green: 247.0 / 255.0, blue: 134.0 / 255.0, alpha: 1).cgColor,
                          UIColor(red: 215.0 / 255.0, green: 238.0 / 255.0, blue: 91.0 / 255.0, alpha: 1).cgColor,
                          UIColor(red: 249.0 / 255.0, green: 87.0 / 255.0, blue: 87.0 / 255.0, alpha: 1).cgColor], direction: .horizontal, frame: viewFriendBox.bounds);
        } else {
            viewFriendBox.applyGradient(colours: [UIColor.dodgerBlue.cgColor, UIColor.brightLightBlue.cgColor], direction: .vertical, frame: viewFriendBox.bounds);
        }
        viewFriendBox.layer.cornerRadius = 10;
        viewFriendBox.clipsToBounds = true;
        
        notifyFriend.backgroundColor = UIColor.clear;
        notifyFriend.setContent(content: "Yay!! 🎊🎉🎊🎉 u guys = amigos");
        
        notifyInstagram.backgroundColor = UIColor.clear;
        notifyInstagram.setContent(content: "The person wants to share this moment on ig 📷 press 🔘 to 🤪😎🤩📷🎥");
    }
    
    override func onSetLocalVideoView(view: UIView) {
        viewLocalContainer.addSubview(view);
//        setFullConstraint(parentView: viewLocalContainer, childView: view)
        view.frame = viewLocalContainer.bounds;
        localVideoView = view;
    }
    
    override func onSetRemoteVideoView(view: UIView) {
        viewRemoteContainer.addSubview(view);
//        setFullConstraint(parentView: viewRemoteContainer, childView: view)
        view.frame = viewRemoteContainer.bounds;
        remoteVideoView = view;
    }
    
    @IBAction func onToggleResize(_ sender: Any) {
        let orgLocalFrame: CGRect = viewLocalContainer.bounds;
        let orgRemoteFrame: CGRect = viewRemoteContainer.bounds;
        
        isLocalSmall = !isLocalSmall;
        
        UIView.animate(withDuration: 0.3, animations: {
            self.localVideoView?.alpha = 0;
            self.remoteVideoView?.alpha = 0;
        }) { (result: Bool) in
            self.localVideoView?.removeFromSuperview();
            self.remoteVideoView?.removeFromSuperview();
            
            
            if (self.isLocalSmall) {
                if (self.localVideoView != nil) {
                    self.viewLocalContainer.addSubview(self.localVideoView!);
                }
                self.viewRemoteContainer.addSubview(self.remoteVideoView!);
                
                self.localVideoView?.frame = orgLocalFrame
                self.remoteVideoView?.frame = orgRemoteFrame;
            } else {
                self.viewLocalContainer.addSubview(self.remoteVideoView!);
                if (self.localVideoView != nil) {
                    self.viewRemoteContainer.addSubview(self.localVideoView!);
                }
                
                self.localVideoView?.frame = orgRemoteFrame
                self.remoteVideoView?.frame = orgLocalFrame;
            }
            UIView.animate(withDuration: 0.3, animations: {
                self.localVideoView?.alpha = 1;
                self.remoteVideoView?.alpha = 1;
            });
        }
        
        /*let orgLocalFrame: CGRect = viewLocalContainer.frame;
        let orgRemoteFrame: CGRect = viewRemoteContainer.frame;
        
        isLocalSmall = !isLocalSmall;
        
        if (self.isLocalSmall) {
            self.setBorder(view: self.viewLocalContainer);
            self.setUnBorder(view: self.viewRemoteContainer);
            self.view.sendSubview(toBack: self.viewRemoteContainer);
        } else {
            self.setBorder(view: self.viewRemoteContainer);
            self.setUnBorder(view: self.viewLocalContainer);
            self.view.sendSubview(toBack: self.viewLocalContainer);
        }
        self.view.bringSubview(toFront: self.btnToggle);
        
        UIView.animate(withDuration: 0.5, animations: {
            self.viewLocalContainer.frame = orgRemoteFrame;
            self.viewRemoteContainer.frame = orgLocalFrame;
        })*/
    }
    
    func setBorder(view: UIView) {
        view.layer.cornerRadius = 10;
        view.clipsToBounds = true;
        view.layer.borderWidth = 1;
        view.layer.borderColor = UIColor.brightLightBlue.cgColor;
    }
    func setUnBorder(view: UIView) {
        view.layer.cornerRadius = 0;
        view.clipsToBounds = true;
        view.layer.borderWidth = 0;
    }
    
    /*func setFullConstraint(parentView: UIView, childView: UIView) {
        parentView.translatesAutoresizingMaskIntoConstraints = false;
    
        let horzCont = NSLayoutConstraint(item: parentView, attribute: .centerX, relatedBy: .equal, toItem: childView, attribute: .centerX, multiplier: 1, constant: 0);
        let vertCont = NSLayoutConstraint(item: parentView, attribute: .centerY, relatedBy: .equal, toItem: childView, attribute: .centerY, multiplier: 1, constant: 0);
        
        let widthCont = NSLayoutConstraint(item: parentView, attribute: .width, relatedBy: .equal, toItem: childView, attribute: .width, multiplier: 1, constant: 0);
        let heightCont = NSLayoutConstraint(item: parentView, attribute: .height, relatedBy: .equal, toItem: childView, attribute: .height, multiplier: 1, constant: 0);
        
        view.addConstraints([horzCont, vertCont, widthCont, heightCont]);
    }*/
    
    @IBAction func onBtnAddFriend(_ sender: Any) {
        btnAddUser.isHidden = true;
        becomeFriend();
    }
    
    override func onBecomeFriend() {
        if (Extern.chat_userInfo ["instagranName"] == nil) {
            lblFriendName.text = Extern.chat_userInfo ["instagranName"] as? String;
            viewFriendBox.isHidden = false;
        }
        viewFriendBox.alpha = 0;
        notifyFriend.alpha = 0;
        UIView.animate(withDuration: 0.5) {
            self.viewFriendBox.alpha = 1;
            self.notifyFriend.alpha = 1;
        }
        
        notifyFriend.isHidden = false;
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            UIView.animate(withDuration: 0.5, animations: {
                self.viewFriendBox.alpha = 0;
                self.notifyFriend.alpha = 0;
            }, completion: { (result: Bool) in
                self.viewFriendBox.isHidden = true;
                self.viewFriendBox.alpha = 1;
                self.notifyFriend.isHidden = true;
            })
        }
    }
    
    @IBAction func onBtnReport(_ sender: Any) {
        let title = "Would you like to report this user?";
        let message = "Our goal is to create a respectful community.\nWe review the reports very seriously.\nPlease don’t hesitate to report inappropriate behaviors. We will take care of the situation 👮‍♂️";
        
        let actionCont = UIAlertController(title: title, message: message, preferredStyle: .actionSheet);
        
        
        let action1 = UIAlertAction(title: "Inappropriate video profile 🙈", style: .default, handler: onReport)
        let action2 = UIAlertAction(title: "Person is nude 🔞", style: .default, handler: onReport)
        let action3 = UIAlertAction(title: "Person is mean 😤", style: .default, handler: onReport)
        let action4 = UIAlertAction(title: "Person is on drugs 🚬", style: .default, handler: onReport)
        let action5 = UIAlertAction(title: "There's other reason 🤐", style: .default, handler: onReport)
        let action6 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionCont.addAction(action1);
        actionCont.addAction(action2);
        actionCont.addAction(action3);
        actionCont.addAction(action4);
        actionCont.addAction(action5);
        actionCont.addAction(action6);
        
        present(actionCont, animated: true, completion: nil);
    }
    
    func onReport(action: UIAlertAction) {
        let id = Extern.transMng.userInfo! ["id"] as! Int;
        Extern.transMng.reportUser(id: id, report: action.title!);
    }
    
    func onClick() {
        becomeRecordable();
    }
    
    override func onBecomeRecordable() {
        notifyInstagram.alpha = 0;
        notifyInstagram.isHidden = false;
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            UIView.animate(withDuration: 0.5, animations: {
                self.notifyInstagram.alpha = 0;
                self.btnInstagram.setBtnState(state: .Enabled);
            }, completion: { (result: Bool) in
                self.notifyInstagram.isHidden = true;
                self.notifyInstagram.alpha = 1;
            })
        }
    }
    
    func onTakePhoto() {
        
    }
    
    func onRecordStart() {
        
    }
    
    func onRecordEnd(time: CGFloat) {
        
    }
    
}

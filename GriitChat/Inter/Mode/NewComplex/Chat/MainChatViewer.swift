//
//  MainChatviewer.swift
//  GriitChat
//
//  Created by GoldHorse on 7/25/18.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit


class MainChatViewer: ChatCoreViewer, RecorderButtonDelegate {
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var viewLocalContainer: GradientView!
    
    @IBOutlet weak var viewRemoteContainer: GradientView!
    
    @IBOutlet weak var btnToggle: UIButton!
    
    @IBOutlet weak var btnAddUser: UIButton!
    
    @IBOutlet weak var btnRecorder: RecorderButton!
    
    @IBOutlet weak var btnReport: UIButton!
    
    @IBOutlet weak var btnSecond: UIButton!
    
    @IBOutlet weak var viewFriendBox: UIView!
    
    @IBOutlet weak var lblFriendName: UILabel!
    
    @IBOutlet weak var notifyFriend: NotifyView!
    
    @IBOutlet weak var notifyInstagram: NotifyView!
    
    @IBOutlet weak var btnRingout: UIButton!
    
    
    @IBOutlet weak var viewProfileBox: UIView!
    
    @IBOutlet weak var profileViewer: ProfileViewer!
    
    @IBOutlet weak var profileOverlay: GradientView!
    
    @IBOutlet weak var imgSmile: UIImageView!
    
    @IBOutlet weak var lblProfileCalling: UILabel!
    
    @IBOutlet weak var imgProfileNextGriiter: UIImageView!
    
    var isLocalSmall = true;
    
    var localFrame: CGRect!;
    
    enum ChatType {
        case Selective;
        case Random;
    }
    var chatType: ChatType!;
    
    var isFriendPage: Bool = false;
    
    var countDownTimer: Timer? = nil;
    var countDownTime: Int = CupManager.RandomCallingDuration;
    
    var chatMode: MainViewPageState? = nil;
    
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        commonInit();
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        commonInit();
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("MainChatViewer", owner: self, options: nil);
        addSubview(contentView);
        contentView.frame = self.bounds;
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight];
        
        viewLocalContainer.setBackColors(colors: [UIColor.dodgerBlue.cgColor, UIColor.brightLightBlue.cgColor]);
        viewRemoteContainer.setBackColors(colors: [UIColor.dodgerBlue.cgColor, UIColor.brightLightBlue.cgColor]);
        
        setBorder(view: viewLocalContainer);
        
        btnSecond.applyGradient(colours: [UIColor.dodgerBlue.cgColor, UIColor.brightLightBlue.cgColor], direction: UIView.GradientDirection.vertical, frame: btnSecond.bounds)
        btnSecond.clipsToBounds = true;
        
        //0.248
        localFrame = CGRect(x: 0.059 * frame.width, y: 0.075 * frame.height, width: 0.191 * frame.width, height: 0.191 * frame.height);
        
        if (self.isLocalSmall) {
            viewRemoteContainer.frame = frame;
            viewLocalContainer.frame = localFrame;
        } else {
            viewRemoteContainer.frame = localFrame;
            viewLocalContainer.frame = frame;
        }
        
        btnToggle.frame = localFrame;
        
        btnToggle.backgroundColor = UIColor.clear;
        
        btnSecond.layer.cornerRadius = btnSecond.bounds.width / 2
        
        /////LEO 20180726
        btnRecorder.layoutSubviews();
        btnRecorder.delegate = self;
    }
    
    override func initState() {
        super.initState();
    }
    
    override func onActive() {
        if (isActive) { return; }
        Extern.mainVC?.camView.stopCamera();
        
        super.onActive();
        
        lblFriendName.text = userInfo! ["instagramName"] as? String;
        setFriendGradient();
        
        let myPhone = Extern.transMng.userInfo! ["phoneNumber"] as! String;
        let otherPhone = userInfo! ["phoneNumber"] as! String;
        
        if (userType == .Caller) {
            fromId = myPhone;
            toId = otherPhone;
        } else {
            fromId = otherPhone;
            toId = myPhone;
        }
        
        btnAddUser.isHidden = false;
        notifyFriend.isHidden = true;
        notifyInstagram.isHidden = true;
        btnRecorder.setRecordEnabled(enabled: false);
        
//        visibleControls(visible: true);
        viewFriendBox.isHidden = true;
        
        
        let isFriend = Extern.dbFriends.checkWithPhoneNumber(phoneNumber: otherPhone);
        
        chatMode = getChatMode();
        
        addHistory();

        Extern.mainVC?.sToolbarView.slideToolbar(ratio: 1, direction: .Down);
        
        btnSecond.setTitle(String(format: "%d", CupManager.RandomCallingDuration), for: .normal);
        
        if (!isFriend &&
            !isReceivedIncomingCall &&
            (chatMode == .Random_Chat || (chatMode == .Friend_Chat && !isFriend))) {
            //Apply 11s rule
            countDownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(onCountingDown), userInfo: nil, repeats: true)
            countDownTime = CupManager.RandomCallingDuration;
            allowEndupCall(isAllow: false);
        } else {
            //Ignore 11s rule
            countDownTime = 0;
        }
        
        
        //Ready for black screen.
        viewProfileBox.isHidden = false;
        visibleControls(visible: false);
        btnRecorder.isHidden = true;
        
        lblProfileCalling.isHidden = false;
        imgProfileNextGriiter.isHidden = true;
        
        if ((chatMode == MainViewPageState.Selective_Chat
            || chatMode == MainViewPageState.Random_Chat)
            && userInfo? ["playerItem"] != nil) {
            profileViewer.isBlurEffect = true;
            profileViewer.createProfileViewer(p_playerItem: userInfo? ["playerItem"] as! CachingPlayerItem,
                                              p_avPlayer: userInfo? ["avPlayer"] as! AVQueuePlayer);
            
            if (chatMode == .Selective_Chat) {
                profileOverlay.alpha = 0.3;
                imgSmile.loadGif(asset: "smile");
                imgSmile.isHidden = false;
                viewLocalContainer.isHidden = false;
            } else {
                profileOverlay.alpha = 0;
                imgSmile.isHidden = true;
                viewLocalContainer.isHidden = true;
                
                lblProfileCalling.isHidden = true;
                imgProfileNextGriiter.isHidden = false;
            }
        } else {
            //History & Friend Chatting...
            profileOverlay.alpha = 0.3;
            
            imgSmile.loadGif(asset: "smile");
            imgSmile.isHidden = false;
            
            viewLocalContainer.isHidden = true;
        }
        
        
        //Virtual Remote Test
        DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
            if (self.kmsPeer?.remoteRenderer != nil) {
                self.rendererDidReceiveVideoData(self.kmsPeer?.remoteRenderer!);
            }
        }
        
        //Virtual Local Test
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let tmpView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200));
            tmpView.backgroundColor = UIColor.white;
            self.onAddLocalStream(localView: tmpView);
        }
    }
    
    override func onDeactive() {
        if (!isActive) { return; }
        
        super.onDeactive();
        
        countDownTimer?.invalidate();
        countDownTimer = nil;
        
        profileViewer.freeState();
        imgSmile.animationImages?.removeAll();
        imgSmile.animationImages = nil;
        imgSmile.image = nil;
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        
        profileViewer.resizePlayerLayer(frame: bounds);
    }
    
    override func onReceiveRemoteVideoData() {
        super.onReceiveRemoteVideoData();
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, animations: {
                self.viewProfileBox.alpha = 0;
            }, completion: { (result) in
                self.viewProfileBox.isHidden = true;
                self.viewProfileBox.alpha = 1;
            })
            
            self.visibleControls(visible: true);
            self.btnRecorder.isHidden = false;
            self.viewRemote?.isHidden = false;
            
            if (self.userInfo? ["playerItem"] == nil) {
                //Make local view as small.
                self.viewLocal?.removeFromSuperview();
                if (self.viewLocal != nil) {
                    self.viewLocalContainer.addSubview(self.viewLocal!);
                }
                self.viewLocal?.frame = self.viewLocalContainer.bounds;
            }
            
            self.onChangeDimension();
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.profileViewer.freeState();
            self.imgSmile.animationImages?.removeAll();
            self.imgSmile.animationImages = nil;
            self.imgSmile.image = nil;
        }
    }
    
    func onRecordStart() {
        visibleControls(visible: false);
    }
    
    func onRecordStop(photoPath: String,  videoPath: String) {
        visibleControls(visible: true);
        //Save Moment
        Extern.dbMoments.addItem(phoneNumber: userInfo! ["phoneNumber"] as! String, photoPath: photoPath, videoPath: videoPath);
    }
    
    func visibleControls(visible: Bool) {
        btnAddUser.isHidden = !visible
        btnReport.isHidden = !visible
        btnSecond.isHidden = !visible
        btnToggle.isHidden = !visible
        
        Extern.mainVC?.sBtnCup.isHidden = !visible;
        
        if (visible) {
            let otherPhone = userInfo! ["phoneNumber"] as! String;
            let isFriend = Extern.dbFriends.checkWithPhoneNumber(phoneNumber: otherPhone);
            if (isFriend) {
                
                if (userInfo! ["instagranName"] != nil
                    && userInfo! ["instagranName"] as! String != "") {
                        viewFriendBox.isHidden = false;
                }
                btnAddUser.isHidden = true;
                setFriendMode(value: true);
                
                friendState = .BeFriend;
            } else {
                viewFriendBox.isHidden = true;
                setFriendMode(value: false);
                friendState = .NoFriend;
            }
            
            if (!isFriend &&
                !isReceivedIncomingCall &&
                (chatMode == MainViewPageState.Random_Chat
                    || (chatMode == MainViewPageState.Friend_Chat && !isFriend))) {
                //Apply 11s rule
                btnSecond.isHidden = false;
            } else {
                //Ignore 11s rule
                btnSecond.isHidden = true;
            }
            
            viewLocalContainer.isHidden = false;
        }
    }
    
    func getChatMode() -> MainViewPageState {
        let statePrefix = Extern.mainVC?.getStatePrefix(state: MainViewPageState(rawValue: pageName)!);
        return (Extern.mainVC?.prefixToChatState(statePrefix: statePrefix!))!;
    }
    
    func setFriendGradient() {
        if (Extern.transMng.userInfo! ["lgbtq"] as! Int == 1
            && userInfo! ["lgbtq"] as! Int == 1) {
            
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
//        setFullConstraint(parentView: viewLocalContainer, childView: view)
        viewLocal = view;
        
        if (!isReceiveRemoteVideo && userInfo? ["playerItem"] == nil) {
            //Make local view as full screen, if videoprofile does not exist.
            viewRemoteContainer.addSubview(viewLocal!);
//            viewLocal?.frame = bounds;
            
            var localDimen: CGSize? = localDimention;
            if (localDimen == nil) {
                localDimen = CGSize(width: 480, height: 640);
            }
            let frame = Extern.getAspectFitRect(orgSize: localDimen!, tgtSize: bounds.size);
            viewLocal?.frame = frame;
        } else {
            viewLocalContainer.addSubview(viewLocal!);
            viewLocal?.frame = viewLocalContainer.bounds;
        }
    }
    
    override func onSetRemoteVideoView(view: UIView) {
        viewRemoteContainer.addSubview(view);
        view.frame = viewRemoteContainer.bounds;
//        setFullConstraint(parentView: viewRemoteContainer, childView: view)
        viewRemote = view;
        
        if (!isReceiveRemoteVideo) {
            viewRemote?.isHidden = true;
        }
    }
    
    @IBAction func onToggleResize(_ sender: Any) {
        if (!isReceiveRemoteVideo) { return }
        
        let orgLocalFrame: CGRect = viewLocalContainer.bounds;
        let orgRemoteFrame: CGRect = viewRemoteContainer.bounds;
        
        isLocalSmall = !isLocalSmall;
        
        UIView.animate(withDuration: 0.2, animations: {
            self.viewLocal?.alpha = 0;
            self.viewRemote?.alpha = 0;
        }) { (result: Bool) in
            self.viewLocal?.removeFromSuperview();
            self.viewRemote?.removeFromSuperview();
            
            
            if (self.isLocalSmall) {
                if (self.viewLocal != nil) {
                    self.viewLocalContainer.addSubview(self.viewLocal!);
                }
                if (self.viewRemote != nil) {
                    self.viewRemoteContainer.addSubview(self.viewRemote!);
                }
                
                self.viewLocal?.frame = orgLocalFrame
                self.viewRemote?.frame = orgRemoteFrame;
            } else {
                if (self.viewRemote != nil) {
                    self.viewLocalContainer.addSubview(self.viewRemote!);
                }
                if (self.viewLocal != nil) {
                    self.viewRemoteContainer.addSubview(self.viewLocal!);
                }
                
                self.viewLocal?.frame = orgRemoteFrame
                self.viewRemote?.frame = orgLocalFrame;
            }
            UIView.animate(withDuration: 0.3, animations: {
                self.viewLocal?.alpha = 1;
                self.viewRemote?.alpha = 1;
                self.onChangeDimension();
            });
        }
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
    
    override func onChangeDimension() {
        if (!isReceiveRemoteVideo) { return }
        
        let orgLocalFrame: CGRect = viewLocalContainer.bounds;
        let orgRemoteFrame: CGRect = viewRemoteContainer.bounds;
        
        if (remoteDimention != nil) {
            let tgtSize: CGSize = isLocalSmall ? orgRemoteFrame.size : orgLocalFrame.size;
            let frame = Extern.getAspectFitRect(orgSize: remoteDimention!, tgtSize: tgtSize);
            viewRemote?.frame = frame;
            
            if (localDimention == nil) {
                localDimention = remoteDimention;
            }
        }
        
        if (localDimention != nil) {
            let frame = Extern.getAspectFitRect(orgSize: localDimention!, tgtSize: viewLocalContainer.bounds.size);
            viewLocal?.frame = frame;
        }
    }
    
    /*func setFullConstraint(parentView: UIView, childView: UIView) {
        parentView.translatesAutoresizingMaskIntoConstraints = false;
    
        let horzCont = NSLayoutConstraint(item: parentView, attribute: .centerX, relatedBy: .equal, toItem: childView, attribute: .centerX, multiplier: 1, constant: 0);
        let vertCont = NSLayoutConstraint(item: parentView, attribute: .centerY, relatedBy: .equal, toItem: childView, attribute: .centerY, multiplier: 1, constant: 0);
        
        let widthCont = NSLayoutConstraint(item: parentView, attribute: .width, relatedBy: .equal, toItem: childView, attribute: .width, multiplier: 1, constant: 0);
        let heightCont = NSLayoutConstraint(item: parentView, attribute: .height, relatedBy: .equal, toItem: childView, attribute: .height, multiplier: 1, constant: 0);
        
        addConstraints([horzCont, vertCont, widthCont, heightCont]);
    }*/
    
    @IBAction func onBtnAddFriend(_ sender: Any) {
        btnAddUser.isHidden = true;
        becomeFriend();
    }
    
    override func onBecomeFriend() {
        if (userInfo! ["instagranName"] != nil
            && userInfo! ["instagranName"] as! String != "") {
            viewFriendBox.isHidden = false;
        }
        viewFriendBox.alpha = 0;
        notifyFriend.alpha = 0;
        
        UIView.animate(withDuration: 0.5, animations: {
            self.viewFriendBox.alpha = 1;
            self.notifyFriend.alpha = 1;
            self.btnReport.alpha = 0;
        }) { (result: Bool) in
            self.btnReport.isHidden = true;
            self.btnReport.alpha = 1;
        }
        
        notifyFriend.isHidden = false;
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            UIView.animate(withDuration: 0.5, animations: {
                self.notifyFriend.alpha = 0;
            }, completion: { (result: Bool) in
                self.notifyFriend.isHidden = true;
            })
        }
        
        addFriend();
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
        
        Extern.mainVC?.present(actionCont, animated: true, completion: nil);
    }
    
    func onReport(action: UIAlertAction) {
        let id = Extern.transMng.userInfo! ["id"] as! Int;
        Extern.transMng.reportUser(id: id, report: action.title!);
        
        afterChatCompletion(true);
    }
    
    
    func onTapEnable() {
        becomeRecordable();
    }
    
    override func onBecomeRecordable() {
        notifyInstagram.alpha = 1;
        notifyInstagram.isHidden = false;
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            UIView.animate(withDuration: 0.5, animations: {
                self.notifyInstagram.alpha = 0;
            }, completion: { (result: Bool) in
                self.notifyInstagram.isHidden = true;
                self.notifyInstagram.alpha = 1;
                self.btnRecorder.setRecordEnabled(enabled: true);
            })
        }
    }
    
    override func afterChatCompletion(_ result: Bool) {
        let curState = MainViewPageState(rawValue: pageName);
        var nextState: MainViewPageState;
        
        if (Extern.mainVC?.navTree [curState!]![1]?.count != 0) {
            nextState = (Extern.mainVC?.navTree [curState!]![1]!.first)!;
        } else if (Extern.mainVC?.navTree [curState!]![0]?.count != 0) {
            nextState = (Extern.mainVC?.navTree [curState!]![0]!.first)!;
        } else {
            let index: String.Index = pageName.index(pageName.startIndex, offsetBy: 1)
            let statePrefix = String(pageName[..<index]);
            
            switch (statePrefix) {
            case "S":
                nextState = .Selective_Loading;
                break;
            case "R":
                nextState = .Random_Init;
                break;
            case "F":
                nextState = .Friend_Main;
                break;
            case "M":
                nextState = .Moment_Main;
                break;
            default:
                fatalError("Unknown incoming state");
            }
        }
        
        if (Extern.isPaused && nextState == .Random_Loading) {
            nextState = .Random_Init;
        }
        
        Extern.mainVC?.gotoPage(nextState);
    }
    
    func addHistory() {
        //Add History
        Extern.dbHistory.addItem(firstName: userInfo! ["firstName"] as! String,
                                 phoneNumber: userInfo! ["phoneNumber"] as! String,
                                 instagramName: userInfo? ["instagramName"] as! String,
                                 countryCode: userInfo! ["country_code"] as! String,
                                 location: userInfo! ["country"] as! String,
                                 photoUrl: userInfo! ["photoUrl"] as! String);
    }
    
    func addFriend() {
        let phoneNumber = userInfo! ["phoneNumber"] as! String;
        if (!Extern.dbFriends.checkWithPhoneNumber(phoneNumber: phoneNumber)) {            
            let lat = userInfo! ["location_lat"]
            let lng = userInfo! ["location_lng"]
            
            Extern.dbFriends.addItem(firstName: userInfo! ["firstName"] as! String,
                                     phoneNumber: userInfo! ["phoneNumber"] as! String,
                                     instagramName: userInfo? ["instagramName"] as! String,
                                     countryCode: userInfo! ["country_code"] as! String,
                                     country: userInfo! ["country"] as! String,
                                     location_lat: (lat as! NSString).floatValue,
                                     location_lng: (lng as! NSString).floatValue,
                                     photoUrl: userInfo! ["photoUrl"] as! String);
        }
    }
    
    @IBAction func onBtnRingout(_ sender: Any) {
        afterChatCompletion(true);
//        Extern.mainVC?.gotoPage(.Friend_Main);
    }
    
    func setFriendMode(value: Bool) {
        btnRingout.isHidden = true;
        btnAddUser.isHidden = value;
        btnReport.isHidden = value;
    }
    
    @objc func onCountingDown(timer: Timer) {
        if (!isReceiveRemoteVideo) { return }
        
        self.btnSecond.setTitle(String(format: "%d", self.countDownTime), for: .normal);
        
        if (countDownTime == 0) {
            self.allowEndupCall(isAllow: true);
            self.countDownTimer?.invalidate();
            self.countDownTimer = nil;
            self.btnSecond.isHidden = true;
        }

        countDownTime -= 1;
    }
    
    func allowEndupCall(isAllow: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if (isAllow) {
                Extern.mainVC?.addRelationPages(MainViewPageState(rawValue: self.pageName)!);
            } else {
                Extern.mainVC?.mainPager.removeExceptOnlyCurPage();
            }
        }
    }
}

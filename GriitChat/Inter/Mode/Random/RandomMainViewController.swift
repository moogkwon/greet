//
//  RandomMainViewController.swift
//  GriitChat
//
//  Created by leo on 18/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit



/*
 +        Swipe              -
 
 toolbar
 isInitState:
 0: Selective       <=      [Init]       =>     Loading
                    (no)                (hide)   (goto:1-anim)
 
 1: Init            <=    [ProfileVC]
 (next:0)      (show)   (goto:2-anim)
 
 2: Init            <=    [MainChating]  =>     Loading
 (next:0)       (show)               (notshow)   (next:3)
 
 3: Init            <=     [Loading]
 (next:0)         (show)  (goto:1-anim)
 */

enum RandomNavState {
    case S_Init_Loading;
    case Init_Profile;
    case Init_Chat_Loading;
    case Init_Loading;
};

class RandomMainViewController: SwipeViewController, SwipeViewControllerDelegate, TransMngRandomDelegate {
    
    
    var sToolbarView: ToolbarView!
    
    var camView: CameraView!;
    
    var prevIndex = 2;
    
    var selectiveVC: SelectiveLoadingViewController!;
    var initVC: RandomInitViewController!;
    var loadingVC: RandomLoadingViewController!;
    var profileVC: RandomViewController!;
    var chattingVC: MainChattingViewController!;
    
    var navState: RandomNavState!;
    
//    var userInfo: Dictionary<String, Any>?;
    
    var _storyboard: UIStoryboard!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main);
        
        navState = Extern.random_navState;
        
        createInit();
        
        switch (navState) {
        case .S_Init_Loading:
            Extern.transMng.resetState();
            
            createSelective();
            createLoading();
            setViewControllerArray([selectiveVC, initVC, loadingVC]);
            setFirstViewController(1);
            break;
        case .Init_Profile:
            createProfile();
            setViewControllerArray([initVC, profileVC]);
            setFirstViewController(1);
            break;
        case .Init_Chat_Loading:
            createChatting();
            createLoading();
            setViewControllerArray([initVC, chattingVC, loadingVC]);
            setFirstViewController(1);
            break;
        case .Init_Loading:
            createLoading();
            setViewControllerArray([initVC, loadingVC]);
            setFirstViewController(1);
            
            loadingVC?.startLoad();
            break;
        default:
            break;
        }
        prevIndex = currentPageIndex;
        
        sToolbarView = ToolbarView.createToolbarView(controller: self);
        
        self.scrollDelegate = self;
        
        camView = CameraView(frame: self.view.bounds);
    }
    
    deinit {
        initVC = nil;
        loadingVC = nil;
    }

    func createSelective() {
        selectiveVC = (_storyboard.instantiateViewController(withIdentifier: "SelectiveLoadingViewController") as! SelectiveLoadingViewController);
    }
    func createInit() {
        initVC = (_storyboard.instantiateViewController(withIdentifier: "RandomInitViewController") as! RandomInitViewController);
        initVC.parentController = self;
    }
    func createLoading() {
        loadingVC = (_storyboard.instantiateViewController(withIdentifier: "RandomLoadingViewController") as! RandomLoadingViewController);
        loadingVC.parentController = self;
    }
    func createProfile() {
        profileVC = (_storyboard.instantiateViewController(withIdentifier: "RandomViewController") as! RandomViewController);
        profileVC.parentController = self;
    }
    
    func createChatting() {
        chattingVC = (_storyboard.instantiateViewController(withIdentifier: "MainChattingViewController") as! MainChattingViewController);
        
        let userType = Extern.chat_userType;
        let myPhone = Extern.transMng.userInfo! ["phoneNumber"] as! String;
        let otherPhone = Extern.chat_userInfo ["phoneNumber"] as! String;
        
        chattingVC.userType = userType;
        if (userType == .Caller) {
            chattingVC.fromId = myPhone;
            chattingVC.toId = otherPhone;
        } else {
            chattingVC.fromId = otherPhone;
            chattingVC.toId = myPhone;
        }
        
        chattingVC.afterChatCompletion = {(result: Bool) -> Void in
            Extern.transMng.resetState();
            
            if (!result) {
                RandomMainViewController.showMainRandom(view: self.view, navState: .S_Init_Loading, isAnimation: true);
            } else {
                RandomMainViewController.showMainRandom(view: self.view, navState: .Init_Loading, isAnimation: true);
            }
        }
        
        Extern.chat_videoPath = nil;
//        Extern.chat_userInfo = nil;
        
        chattingVC.parentController = self;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        sToolbarView.setActive(tabName: .Random)
        
        if (navState == .S_Init_Loading) {
            sToolbarView.slideToolbar(centerX: self.view.bounds.width, direction: .Up);
            Extern.transMng.randomDelegate = nil;
        } else {
            sToolbarView.slideToolbar(centerX: self.view.bounds.width, direction: .Down);
            Extern.transMng.randomDelegate = self;
        }
        
        if (navState != .Init_Chat_Loading) {
            _ = camView.setupAVCapture();
            pageController.view.insertSubview(camView, at: 0);
        }
    }
    
    func onDidScroll(fromCenterX: CGFloat, currentIndex: Int) {
        
        switch (navState) {
        case .S_Init_Loading:
            if (currentIndex == 2) {
                Extern.transMng.randomDelegate = nil;
                if (fromCenterX < 0) {
                    sToolbarView.slideToolbar(centerX: fromCenterX, direction: .Down);
                }
            } else if (currentIndex == 3) {
                sToolbarView.slideToolbar(centerX: fromCenterX, direction: .Up);
                Extern.transMng.randomDelegate = self;
            }
            break;
        case .Init_Profile:
            sToolbarView.slideToolbar(centerX: fromCenterX, direction: .Up);
            break;
        case .Init_Chat_Loading:
            if (currentIndex == 2 && fromCenterX > 0) {
                sToolbarView.slideToolbar(centerX: fromCenterX, direction: .Up);
            }
            break;
        case .Init_Loading:
            sToolbarView.slideToolbar(centerX: fromCenterX, direction: .Up);
            break;
        default:
            break;
        }
        
        if (currentIndex == prevIndex) {
            return;
        }
        
        switch (navState) {
        case .S_Init_Loading:
            if (currentIndex == 1) {
                //Show Selective;
                Extern.transMng.resetState();
                SelectiveMainViewController.showMainSelective(view: self.view, navState: .Loading, isAnimation: false);
            } else if (currentIndex == 2) {
                Extern.transMng.resetState();
            } else {
                loadingVC?.startLoad();
            }
            break;
        case .Init_Profile:
            if (currentIndex == 1) {
                Extern.transMng.resetState();
                RandomMainViewController.showMainRandom(view: view, navState: .S_Init_Loading, isAnimation: false);
            }
            break;
        case .Init_Chat_Loading:
            if (currentIndex == 1) {
                chattingVC.stopChatting();
                Extern.transMng.resetState();
                RandomMainViewController.showMainRandom(view: view, navState: .S_Init_Loading, isAnimation: false);
            } else if (currentIndex == 3) {
                chattingVC.stopChatting();
                Extern.transMng.resetState();
                RandomMainViewController.showMainRandom(view: view, navState: .Init_Loading, isAnimation: false);
            }
            break;
        case .Init_Loading:
            if (currentIndex == 1) {
                Extern.transMng.resetState();
                RandomMainViewController.showMainRandom(view: view, navState: .S_Init_Loading, isAnimation: false);
            }
            break;
        default:
            break;
        }
        prevIndex = currentIndex;
    }
    /*
    func animateToolbarView() {
        sToolbarView.center.y = view.bounds.height + sToolbarView.bounds.height / 2;
        
        UIView.animate(withDuration: 1) {
            self.sToolbarView.center.y = self.view.bounds.height - self.sToolbarView.bounds.height / 2;
        }
    }*/
    
    func onStartRandomResponse(result: Int, data: Dictionary<String, Any>) {
        if (result == -1) {
            //Failed.
            showMessage(title: "Random Mode", content: data ["message"] as! String, completion: {
                Extern.transMng.resetState();
                RandomMainViewController.showMainRandom(view: self.view, navState: .Init_Loading, isAnimation: true)
            });
        }
        if (result == 3 || result == 4) {
            if (navState == .S_Init_Loading) {
                Extern.chat_userInfo = data;
                loadingVC?.startLoadVideo(userId: data ["id"] as! Int);
                Extern.chat_userType = result == 4 ? .Caller : .Callee;
            }
        }
    }
    
    func onRecvVideoComplete(result: Bool, videoPath: String?) {
        if (result) {
            Extern.chat_videoPath = videoPath!;
            RandomMainViewController.showMainRandom(view: view, navState: .Init_Profile, isAnimation: true)
        } else {
            Extern.transMng.resetState();
            RandomMainViewController.showMainRandom(view: view, navState: .Init_Loading, isAnimation: true)
        }
    }
    
    static func showMainRandom(view: UIView?, navState: RandomNavState, isAnimation: Bool) {
        let pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        
        Extern.random_navState = navState;
        
        let navigationController = RandomMainViewController(rootViewController: pageController);
        
        if (isAnimation) {
            let transition = CATransition()
            transition.duration = 0.5
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromRight
            transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
            view?.window!.layer.add(transition, forKey: kCATransition)
        }
        
        UIApplication.shared.delegate?.window??.rootViewController = navigationController;
        UIApplication.shared.delegate?.window??.makeKeyAndVisible();
        
        view?.isHidden = true;
        view?.setNeedsDisplay();
    }
    func onReadyRandomCallee(result: Int) {
        
    }
}

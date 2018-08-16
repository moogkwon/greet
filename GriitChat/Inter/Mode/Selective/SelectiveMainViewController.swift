//
//  SelectiveMainViewController.swift
//  GriitChat
//
//  Created by leo on 18/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit

/*
 0: [Loading]
 (goto:1-anim)
 
 1: [Profile]     =>      Loading
 (goto:2-anim)            (next: 0)
 
 2: [Chatting]    =>      Loading
 (goto:0-anim)  (show)    (next: 0)
 */
enum SelectiveNavState {
    case Loading;
    case Profile_Loading;
    case Chat_Loading;
}

class SelectiveMainViewController: SwipeViewController, SwipeViewControllerDelegate {
    var sToolbarView: ToolbarView!
    
    var loadingVC: SelectiveLoadingViewController!;
    var profileVC: SelectiveViewController!;
    var chattingVC: MainChattingViewController!;
    
    var prevIndex = 1;
    
    var _storyboard: UIStoryboard!;
    var navState: SelectiveNavState!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main);
        
        navState = Extern.selective_navState;
        
        createLodaing();
        
        switch (navState) {
        case .Loading:
            setViewControllerArray([loadingVC]);
            setFirstViewController(0);
            Extern.transMng.resetState();
            loadingVC.startLoad();
            break;
        case .Profile_Loading:
            createProfile();
            setViewControllerArray([profileVC, loadingVC]);
            break;
        case .Chat_Loading:
            createChatting();
            setViewControllerArray([chattingVC, loadingVC]);
            break;
        default:
            break;
        }
        
        sToolbarView = ToolbarView.createToolbarView(controller: self);
        
        self.scrollDelegate = self;
    }
    
    deinit {
        loadingVC = nil;
        profileVC = nil;
    }
    
    func createLodaing() {
        loadingVC = (_storyboard.instantiateViewController(withIdentifier: "SelectiveLoadingViewController") as! SelectiveLoadingViewController);
        loadingVC.parentController = self;
    }
    
    func createProfile() {
        profileVC = (_storyboard.instantiateViewController(withIdentifier: "SelectiveViewController") as! SelectiveViewController);
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
            if (!result) {
                Extern.transMng.resetState();
                SelectiveMainViewController.showMainSelective(view: self.view, navState: .Loading, isAnimation: true);
            } else {
                Extern.transMng.resetState();
                SelectiveMainViewController.showMainSelective(view: self.view, navState: .Loading, isAnimation: true);
            }
        }
        
        Extern.chat_videoPath = nil;
        Extern.chat_userInfo = nil;
        
        chattingVC.parentController = self;
    }
    
    override func viewDidLayoutSubviews() {
        sToolbarView.setActive(tabName: .Selective)
        
        if (navState == .Chat_Loading) {
            sToolbarView.slideToolbar(centerX: self.view.bounds.width, direction: .Down);
        } else {
            sToolbarView.slideToolbar(centerX: self.view.bounds.width, direction: .Up);
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onDidScroll(fromCenterX: CGFloat, currentIndex: Int) {
        
        switch (navState) {
        case .Loading: break;
        case .Profile_Loading: break;
        case .Chat_Loading:
            sToolbarView.slideToolbar(centerX: fromCenterX, direction: .Up);
            break;
        default:
            break;
        }
        if (currentIndex == prevIndex) {
            return;
        }
        
        switch (navState) {
        case .Loading: break;
        case .Profile_Loading:
            if (currentIndex == 2) {
                profileVC.freeClass();
                SelectiveMainViewController.showMainSelective(view: view, navState: .Loading, isAnimation: false);
            }
            break;
        case .Chat_Loading:
            if (currentIndex == 2) {
                SelectiveMainViewController.showMainSelective(view: view, navState: .Loading, isAnimation: false);
            }
            break;
        default:
            break;
        }
        prevIndex = currentIndex;
    }
    
    static func showMainSelective(view: UIView?, navState: SelectiveNavState, isAnimation: Bool) {
        let pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        
        Extern.selective_navState = navState;
        
        let navigationController = SelectiveMainViewController(rootViewController: pageController);
        
        if (isAnimation) {
            do {
                let transition = CATransition()
                transition.duration = 0.5
                transition.type = kCATransitionPush
                transition.subtype = kCATransitionFromRight
                transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
                try view?.window!.layer.add(transition, forKey: kCATransition)
            } catch let e {
                debugPrint(e.localizedDescription);
            }
        }
        
        UIApplication.shared.delegate?.window??.rootViewController = navigationController;
        UIApplication.shared.delegate?.window??.makeKeyAndVisible();
        
        view?.isHidden = true;
        view?.removeFromSuperview();
    }
}

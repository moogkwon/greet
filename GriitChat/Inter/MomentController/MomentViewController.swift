//
//  MomentViewController.swift
//  GriitChat
//
//  Created by leo on 15/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit

class MomentViewController: UIViewController, ScrollPagerDelegate {
    
    @IBOutlet weak var scrollPager: ScrollPager!
    
    @IBOutlet weak var btnMoments: UIButton!
    
    @IBOutlet weak var btnSettings: UIButton!
    
    @IBOutlet weak var borderMoments: UIView!
    
    @IBOutlet weak var borderSettings: UIView!
    
    var sToolbarView: ToolbarView!
    
    var momentPage: MomentPage? = nil;
    var settingPage: SettingPage? = nil;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        borderSettings.isHidden = true;
        
        sToolbarView = ToolbarView.createToolbarView(controller: self);
        sToolbarView.isTransparent = false;
        scrollPager.pageDelegate = self;
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        
        if (momentPage == nil) {
            momentPage = MomentPage(frame: scrollPager.frame);
            momentPage?.pageName = "MomentPage";
            
            _ = scrollPager.addPage(page: momentPage!);
        }
        if (settingPage == nil) {
            settingPage = SettingPage(frame: scrollPager.frame);
            settingPage?.pageName = "SettingPage";
            
            _ = scrollPager.addPage(page: settingPage!);
        }
        
        sToolbarView.setActive(tabName: .Moment);
    }
    
    @IBAction func onBtnMoments(_ sender: Any) {
        activeMoments();
        scrollPager.scrollToIndex(index: 0);
    }
    
    @IBAction func onBtnSettings(_ sender: Any) {
        activeSettings();
        scrollPager.scrollToIndex(index: 1);
    }
    
    func activeMoments() {
        borderMoments.isHidden = false;
        borderSettings.isHidden = true;
    }
    
    func activeSettings() {
        borderMoments.isHidden = true;
        borderSettings.isHidden = false;
    }
    
    func onChangeCurrentPage(index: Int) {
        DispatchQueue.main.async {
            if (index == 0) {
                self.activeMoments();
            } else {
                self.activeSettings();
            }
        }
    }
    
    func onScroll(currentPage: Int, offset: CGFloat) {
        
    }
    
    static func showMoments(view: UIView?) {
        let navigationController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MomentViewController") as! MomentViewController;
        
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view?.window!.layer.add(transition, forKey: kCATransition)
        
        UIApplication.shared.delegate?.window??.rootViewController = navigationController;
        UIApplication.shared.delegate?.window??.makeKeyAndVisible();
        
        view?.isHidden = true;
        view?.setNeedsDisplay();
    }
}


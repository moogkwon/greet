//
//  MomentMainPage.swift
//  GriitChat
//
//  Created by leo on 26/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit

class MomentMainPage: ViewPage, ScrollPagerDelegate {
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var scrollPager: ScrollPager!
    
    @IBOutlet weak var btnMoments: UIButton!
    
    @IBOutlet weak var btnSettings: UIButton!
    
    @IBOutlet weak var borderMoments: UIView!
    
    @IBOutlet weak var borderSettings: UIView!
    
    @IBOutlet weak var imgMoments: UIImageView!
    
    @IBOutlet weak var imgSettings: UIImageView!
    
    var momentPage: MomentPage? = nil;
    var settingPage: SettingPage? = nil;
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        commonInit();
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        commonInit();
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("MomentMainPage", owner: self, options: nil);
        addSubview(contentView);
        contentView.frame = self.bounds;
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight];
        
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
        
        borderSettings.isHidden = true;
        scrollPager.pageDelegate = self;
    }
    
    override func initState() {
        super.initState()
        momentPage?.parentVC = parentVC;
        settingPage?.parentVC = parentVC;
    }
    
    override func onActive() {
        if (isActive) { return }
        
        super.onActive();
        Extern.transMng.resetState();
        
//        momentPage?.onActive();
//        settingPage?.onActive();
        if (scrollPager.getPageIndex() == 0) {
            momentPage?.onActive();
        } else {
            settingPage?.onActive();
        }
        
        DispatchQueue.main.async {
            Extern.mainVC?.sToolbarView.slideToolbar(ratio: 1, direction: .Up);
            Extern.mainVC?.sBtnCup.isHidden = true;
        }
        Extern.mainVC?.camView.stopCamera();
    }
    
    override func onDeactive() {
        if (!isActive) { return }
        
        super.onDeactive();
        momentPage?.onDeactive();
        settingPage?.onDeactive();
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        
        momentPage?.layoutSubviews();
        settingPage?.layoutSubviews();
    }
    
    @IBAction func onBtnMoments(_ sender: Any) {
        if (scrollPager.getPageIndex() == 0) { return }
        
        activeMoments();
        scrollPager.scrollToIndex(index: 0, duration: 0.5, completion: nil);
        
        momentPage?.onActive();
        settingPage?.onDeactive();
    }
    
    @IBAction func onBtnSettings(_ sender: Any) {
        if (scrollPager.getPageIndex() == 1) { return }
        
        activeSettings();
        scrollPager.scrollToIndex(index: 1, duration: 0.5, completion: nil);
        
        momentPage?.onDeactive();
        settingPage?.onActive();
    }
    
    func activeMoments() {
        borderMoments.isHidden = false;
        borderSettings.isHidden = true;
        
        btnMoments.alpha = 1;
        btnSettings.alpha = 0.5;
        
        imgMoments.alpha = 1;
        imgSettings.alpha = 0.5;
        
        momentPage?.layoutSubviews();
    }
    
    func activeSettings() {
        borderMoments.isHidden = true;
        borderSettings.isHidden = false;
        
        btnMoments.alpha = 0.5;
        btnSettings.alpha = 1;
        
        imgMoments.alpha = 0.5;
        imgSettings.alpha = 1;
        
        settingPage?.layoutSubviews();
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
}

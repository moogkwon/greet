//
//  FriendViewController.swift
//  GriitChat
//
//  Created by leo on 15/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit

class FriendViewController: UIViewController, ScrollPagerDelegate {
    @IBOutlet weak var scrollPager: ScrollPager!
    
    @IBOutlet weak var btnFriend: UIButton!
    
    @IBOutlet weak var btnHistory: UIButton!
    
    @IBOutlet weak var borderFriend: UIView!
    
    @IBOutlet weak var borderHistory: UIView!
    
    var sToolbarView: ToolbarView!
    
    var friendPage: FriendPage? = nil;
    var historyPage: HistoryPage? = nil;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        borderHistory.isHidden = true;
        
        sToolbarView = ToolbarView.createToolbarView(controller: self);
        sToolbarView.isTransparent = false;
        scrollPager.pageDelegate = self;
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        
        if (friendPage == nil) {
            friendPage = FriendPage(frame: scrollPager.frame);
            friendPage?.pageName = "FriendPage";
            
            _ = scrollPager.addPage(page: friendPage!);
        }
        if (historyPage == nil) {
            historyPage = HistoryPage(frame: scrollPager.frame);
            historyPage?.pageName = "HistoryPage";
            
            _ = scrollPager.addPage(page: historyPage!);
        }
        
        sToolbarView.setActive(tabName: .Friend);
    }
    
    @IBAction func onBtnFriend(_ sender: Any) {
        activeFriend();
        scrollPager.scrollToIndex(index: 0);
    }
    
    @IBAction func onBtnHistory(_ sender: Any) {
        activeHistory();
        scrollPager.scrollToIndex(index: 1);
    }
    
    func activeFriend() {
        borderFriend.isHidden = false;
        borderHistory.isHidden = true;
    }
    
    func activeHistory() {
        borderFriend.isHidden = true;
        borderHistory.isHidden = false;
    }
    
    func onChangeCurrentPage(index: Int) {
        DispatchQueue.main.async {
            if (index == 0) {
                self.activeFriend();
            } else {
                self.activeHistory();
            }
        }
    }
    
    func onScroll(currentPage: Int, offset: CGFloat) {
        
    }
    
    static func showFriend(view: UIView?) {
        let navigationController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FriendViewController") as! FriendViewController;
        
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

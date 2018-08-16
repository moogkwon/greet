//
//  FriendMainPage.swift
//  GriitChat
//
//  Created by leo on 26/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit

class FriendMainPage: ViewPage, ScrollPagerDelegate, TransMngCheckOnlineUsersDelegate {
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var scrollPager: ScrollPager!
    
    @IBOutlet weak var btnFriend: UIButton!
    
    @IBOutlet weak var btnHistory: UIButton!
    
    @IBOutlet weak var borderFriend: UIView!
    
    @IBOutlet weak var borderHistory: UIView!
    
    @IBOutlet weak var imgFriend: UIImageView!
    
    @IBOutlet weak var imgHistory: UIImageView!
    
    var friendPage: FriendPage? = nil;
    var historyPage: HistoryPage? = nil;
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        commonInit();
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        commonInit();
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("FriendMainPage", owner: self, options: nil);
        addSubview(contentView);
        contentView.frame = self.bounds;
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight];
        
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
        borderHistory.isHidden = true;
        scrollPager.pageDelegate = self;
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        
        friendPage?.layoutSubviews();
        historyPage?.layoutSubviews();
    }
    
    override func initState() {
        super.initState()
        friendPage?.parentVC = parentVC;
        historyPage?.parentVC = parentVC;
    }
    
    override func onActive() {
        if (isActive) { return }
        
        super.onActive();
        Extern.transMng.resetState();
        checkOnlineStatus();
        
        friendPage?.onActive();
        historyPage?.onActive();
        
        DispatchQueue.main.async {
            Extern.mainVC?.sToolbarView.slideToolbar(ratio: 1, direction: .Up);
            Extern.mainVC?.sBtnCup.isHidden = true;
        }
        Extern.mainVC?.camView.stopCamera();
    }
    
    override func onDeactive() {
        if (!isActive) { return }
        super.onDeactive();
        
        friendPage?.onDeactive();
        historyPage?.onDeactive();
    }
    
    @IBAction func onBtnFriend(_ sender: Any) {
        activeFriend();
        scrollPager.scrollToIndex(index: 0, duration: 0.5, completion: nil);
    }
    
    @IBAction func onBtnHistory(_ sender: Any) {
        activeHistory();
        scrollPager.scrollToIndex(index: 1, duration: 0.5, completion: nil);
    }
    
    func activeFriend() {
        borderFriend.isHidden = false;
        borderHistory.isHidden = true;
        
        btnFriend.alpha = 1;
        btnHistory.alpha = 0.5;
        
        imgFriend.alpha = 1;
        imgHistory.alpha = 0.5;
    }
    
    func activeHistory() {
        borderFriend.isHidden = true;
        borderHistory.isHidden = false;
        
        btnFriend.alpha = 0.5;
        btnHistory.alpha = 1;
        
        imgFriend.alpha = 0.5;
        imgHistory.alpha = 1;
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
    
    func checkOnlineStatus() {
        var friendItems = Extern.dbFriends.getAllItems();
        var historyItems = Extern.dbHistory.getAllItems();
        
        var phoneList: [String] = [String]();
        for item in historyItems {
            phoneList.append(item.phoneNumber!);
        }
        for friend in friendItems {
            var isDouble = false;
            for history in historyItems {
                if (history.phoneNumber == friend.phoneNumber) {
                    isDouble = true;
                    break;
                }
            }
            if (!isDouble) {
                phoneList.append(friend.phoneNumber!);
            }
        }
        
        Extern.transMng.onlineUsersDelegate = self;
        _ = Extern.transMng.checkOnlineUsers(phoneList);
        
        phoneList.removeAll();
        friendItems.removeAll();
        historyItems.removeAll();
    }
    
    func onCheckOnlineUsersResponse(data: [String : Int]) {
        friendPage?.markOnlineUsers(data: data);
        historyPage?.markOnlineUsers(data: data);
    }
}

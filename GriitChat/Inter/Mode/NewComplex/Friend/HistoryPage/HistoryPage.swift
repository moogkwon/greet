//
//  HistoryPage.swift
//  GriitChat
//
//  Created by GoldHorse on 7/23/18.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit

class HistoryPage: ViewPage, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, FriendCellDelegate {
    
    @IBOutlet var contentView: UIScrollView!
    
    @IBOutlet weak var innerView: UIView!
    
    @IBOutlet weak var tblHistoryBox: UIView!
    
    @IBOutlet weak var tblHistory: UITableView!
    
    @IBOutlet weak var tblSearchBar: UISearchBar!
    
    @IBOutlet weak var tblConstraint: NSLayoutConstraint!
    
    var historyItems: [History]!;
    var filteredItems: [History]? = nil;
    var itemCount = 0;
    var cellHeight: CGFloat = 0.0;
    var contentSize: CGRect!;
    
    var onlineStatus: [String: Int]? = nil;
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        commonInit();
        debugPrint("Frame_init : ", frame);
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        commonInit();
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("HistoryPage", owner: self, options: nil);
        addSubview(contentView);
        contentView.frame = self.bounds;
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight];
        tblHistory.dataSource = self;
        tblHistory.delegate = self;
        tblSearchBar.delegate = self
        
        cellHeight = bounds.width / 6;
        
        let itemPressRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapPress))
        contentView.addGestureRecognizer(itemPressRecognizer)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress))
        contentView.addGestureRecognizer(longPressRecognizer)
    }
    
    override func initState() {
        super.initState();
        historyItems = Extern.dbHistory.getAllItems();
        itemCount = historyItems.count;
    }
    
    override func onActive() {
        if (isActive) { return }
        super.onActive();
        
        historyItems?.removeAll();
        historyItems = nil;
        
        historyItems = Extern.dbHistory.getAllItems();
        itemCount = historyItems.count;
        tblHistory.reloadData();
    }
    override func onDeactive() {
        if (!isActive) { return }
        super.onDeactive();
        
        historyItems?.removeAll();
        historyItems = nil;
        
        filteredItems?.removeAll();
        filteredItems = nil;
        
        searchBarCancelButtonClicked(tblSearchBar);
    }
    
    var tblHeight: CGFloat = 0;
    override func updateConstraints() {
        super.updateConstraints();
        
        let estimateHeight: CGFloat = cellHeight * CGFloat(itemCount) + tblSearchBar.frame.height;
        tblHeight = estimateHeight;
        tblConstraint.constant = tblHeight;
    }
    override func layoutSubviews() {
        super.layoutSubviews();
        
        contentView.contentSize = CGSize(width: contentView.frame.width, height: tblHeight);
    }
    
    @objc func onTapPress(tapGestureRecognizer: UITapGestureRecognizer) {
        endEditing(true)
    }
    
    @objc func onLongPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == UIGestureRecognizerState.began {
            let touchPoint = longPressGestureRecognizer.location(in: tblHistoryBox)
            if let indexPath = tblHistory.indexPathForRow(at: touchPoint) {
                onLongPressed(indexPath: indexPath);
                return;
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tblHistory.frame = CGRect(x: 0, y: 0, width: bounds.width, height: tblHeight);
        tblHistory.contentSize = CGSize(width: bounds.width, height: tblHeight);
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (filteredItems == nil) {
            return historyItems != nil ? historyItems.count : 0;
        } else {
            return (filteredItems?.count)!;
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("FriendTableCell", owner: self, options: nil)?.first as! FriendTableCell;
        
        cell.indexPath = indexPath;
        cell.delegate = self;
        
        cell.btnInstagram.isHidden = true;
        
        var item: History!;
        if (filteredItems == nil) {
            item = historyItems [indexPath.row];
        } else {
            item = filteredItems! [indexPath.row];
        }
        cell.imgUser.setImage(url: URL(string: item.photoUrl!), defaultImgName: Assets.Default_User_Image);
        cell.lblName.text = item.firstName;
        cell.lblLocation.text = item.location! + "  " + Extern.getCountryFlag(countryCode: item.countryCode!, phoneNumber: item.phoneNumber!);
        
        if (onlineStatus != nil) {
            cell.btnChat.isHidden = (onlineStatus! [item.phoneNumber!] == 0);
        }
        return cell;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredItems = searchText.isEmpty ? nil : historyItems.filter({(item: History) -> Bool in
            // If dataItem matches the searchText, return true to include it
            return item.firstName?.range(of: searchText, options: .caseInsensitive) != nil
                || item.location?.range(of: searchText, options: .caseInsensitive) != nil
        })
        
        tblHistory.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.tblSearchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        tblSearchBar.showsCancelButton = false
        tblSearchBar.text = ""
        filteredItems = nil;
        tblSearchBar.resignFirstResponder()
        tblHistory.reloadData()
    }
    
    func onClickVideo(indexPath: IndexPath) {
        var phoneNumber: String? = nil;
        if (filteredItems == nil) {
            phoneNumber = historyItems [indexPath.row].phoneNumber;
        } else {
            phoneNumber = filteredItems? [indexPath.row].phoneNumber;
        }
        Extern.mainVC?.chatLoadWithCam.phoneNumber = phoneNumber;
        Extern.mainVC?.gotoPage(.Friend_Loading);
        
        Extern.mainVC?.chattingPage.isFriendPage = false;
    }
    
    func onClickInstagram(indexPath: IndexPath) {
        debugPrint("Instagram: ", indexPath)
    }
    
    var longPressedIndex: IndexPath? = nil;
    func onLongPressed(indexPath: IndexPath) {
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
        
        longPressedIndex = indexPath;
    }
    
    func onReport(action: UIAlertAction) {
        
        var phoneNumber: String? = nil;
        if (filteredItems == nil) {
            phoneNumber = historyItems [(longPressedIndex?.row)!].phoneNumber;
        } else {
            phoneNumber = filteredItems? [(longPressedIndex?.row)!].phoneNumber;
        }
        Extern.transMng.reportUser(phoneNumber: phoneNumber!, report: action.title!);
    }
    
    func markOnlineUsers(data: [String: Int]) {
        onlineStatus?.removeAll();
        
        onlineStatus = data;
        tblHistory.reloadData();
    }
}

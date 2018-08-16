//
//  FriendPage.swift
//  GriitChat
//
//  Created by GoldHorse on 7/23/18.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit
import SwiftInstagram

class FriendPage: ViewPage, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, FriendCellDelegate {

    @IBOutlet var contentView: UIScrollView!
    
    @IBOutlet weak var innerView: UIView!
    
    @IBOutlet weak var mapView: UIView!
    
    @IBOutlet weak var mapContainer: UIView!
    
    @IBOutlet weak var tblFriendBox: UIView!
    
    @IBOutlet weak var tblFriends: UITableView!
    
    @IBOutlet weak var tblSearchBar: UISearchBar!
    
    @IBOutlet weak var tblConstraint: NSLayoutConstraint!
    
    var friendItems: [Friends]!;
    var filteredItems: [Friends]? = nil;
    var itemCount = 0;
    var cellHeight: CGFloat = 0.0;
    var contentSize: CGRect!;
    
    var onlineStatus: [String: Int]? = nil;
    
    var pinList: [String: UIImageView] = [String: UIImageView]();
    
    let pinSize: CGFloat = 10.0;
    var selectedFriend: Friends? = nil;
    
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
        Bundle.main.loadNibNamed("FriendPage", owner: self, options: nil);
        addSubview(contentView);
        contentView.frame = self.bounds;
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight];
        tblFriends.dataSource = self;
        tblFriends.delegate = self;
        tblSearchBar.delegate = self
        
        cellHeight = bounds.width / 6;
/*
        let photoPath = FileManager.makeTempPath("png");
        
        let img: UIImage = UIImage(named: "instagram")!
        _ = img.saveImage(savePath: photoPath);
        
        Extern.dbFriends.addItem(firstName: "0NewYork", phoneNumber: "12342345678", instagramName: "NewYork", countryCode: "US", country: "United State", location_lat: 40.730610, location_lng: -73.935242, photoPath: photoPath)
        
        Extern.dbFriends.addItem(firstName: "0Moscow", phoneNumber: "13342345678", instagramName: "Moscow", countryCode: "US", country: "United State", location_lat: 55.751244, location_lng: 37.618423, photoPath: photoPath)
        
        Extern.dbFriends.addItem(firstName: "Tokyo", phoneNumber: "16342345678", instagramName: "Tokyo", countryCode: "US", country: "Japan", location_lat: 35.652832, location_lng: 139.839478, photoPath: photoPath)*/
        
        let itemPressRecognizer = UITapGestureRecognizer(target: self, action: #selector(onItemPress))
        contentView.addGestureRecognizer(itemPressRecognizer)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress))
        contentView.addGestureRecognizer(longPressRecognizer)
    }
    
    override func initState() {
        super.initState();
        
        friendItems = Extern.dbFriends.getAllItems();
        itemCount = friendItems.count;
    }
    
    override func onActive() {
        if (isActive) { return }
        super.onActive();
        
        friendItems?.removeAll();
        friendItems = nil;
        
        friendItems = Extern.dbFriends.getAllItems();
        itemCount = friendItems.count;
        
        sortFriendWithOnlineStatus();
        
        DispatchQueue.main.async {
            self.tblFriends.reloadData();
            self.addPins();
        }
    }
    
    override func onDeactive() {
        if (!isActive) { return }
        super.onDeactive();
        friendItems?.removeAll();
        friendItems = nil;
        
        filteredItems?.removeAll();
        filteredItems = nil;
        
        removePins();
        
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
        
        contentView.contentSize = CGSize(width: contentView.frame.width, height: tblHeight + mapView.frame.height);
        
        /*tblSearchBar.layer.cornerRadius = tblSearchBar.frame.height / 2;
        tblSearchBar.clipsToBounds = true;
        
        tblFriends.layer.cornerRadius = cellHeight / 2;
        tblFriends.clipsToBounds = true;
        tblFriendBox.layer.cornerRadius = 100;//cellHeight / 2;
        tblFriendBox.clipsToBounds = true;*/
        
//        addPinToMap(lat: 40.730610, lng: -73.935242);
        
        DispatchQueue.main.async {
            self.addPins();
        }
    }
    
    
    @objc func onItemPress(tapGestureRecognizer: UITapGestureRecognizer) {
        endEditing(true)
        
        let touchPoint = tapGestureRecognizer.location(in: tblFriendBox)
        if let indexPath = tblFriends.indexPathForRow(at: touchPoint) {
            DispatchQueue.main.async {
                self.onItemPressed(indexPath: indexPath);
            }
            return;
        }
    }
    
    @objc func onLongPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == UIGestureRecognizerState.began {
            let touchPoint = longPressGestureRecognizer.location(in: tblFriendBox)
            if let indexPath = tblFriends.indexPathForRow(at: touchPoint) {
                onLongPressed(indexPath: indexPath);
                return;
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tblFriends.frame = CGRect(x: 0, y: 0, width: bounds.width, height: tblHeight);
        tblFriends.contentSize = CGSize(width: bounds.width, height: tblHeight);
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rtnValue = 0;
        if (filteredItems == nil) {
            rtnValue = friendItems != nil ? friendItems.count : 0;
        } else {
            rtnValue = (filteredItems?.count)!;
        }
        return rtnValue;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("FriendTableCell", owner: self, options: nil)?.first as! FriendTableCell;
        
        cell.indexPath = indexPath;
        cell.delegate = self;
        
        var item: Friends!;
        if (filteredItems == nil) {
            item = friendItems [indexPath.row];
        } else {
            item = filteredItems! [indexPath.row];
        }
        
        cell.imgUser.setImage(url: URL(string: item.photoUrl!), defaultImgName: Assets.Default_User_Image);        
        cell.lblName.text = item.firstName;
        cell.lblLocation.text = item.country! + "  " + Extern.getCountryFlag(countryCode: item.countryCode!, phoneNumber: item.phoneNumber!);
        
        cell.btnInstagram.isHidden = item.instagramName == "";
        
        if (onlineStatus != nil) {
            cell.btnChat.isHidden = (onlineStatus! [item.phoneNumber!] == 0);
        }
        return cell;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredItems = searchText.isEmpty ? nil : friendItems.filter({(item: Friends) -> Bool in
            // If dataItem matches the searchText, return true to include it
            return item.firstName?.range(of: searchText, options: .caseInsensitive) != nil
                || item.country?.range(of: searchText, options: .caseInsensitive) != nil
        })
        
        tblFriends.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.tblSearchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        tblSearchBar.showsCancelButton = false
        tblSearchBar.text = ""
        filteredItems?.removeAll();
        filteredItems = nil;
        tblSearchBar.resignFirstResponder()
        tblFriends.reloadData()
    }
    
    func onClickVideo(indexPath: IndexPath) {
        var phoneNumber: String? = nil;
        if (filteredItems == nil) {
            phoneNumber = friendItems [indexPath.row].phoneNumber;
        } else {
            phoneNumber = filteredItems? [indexPath.row].phoneNumber;
        }
        
        if (phoneNumber == Extern.transMng.userInfo! ["phoneNumber"] as! String) { return; }
        
        Extern.mainVC?.chatLoadWithCam.phoneNumber = phoneNumber;
        Extern.mainVC?.gotoPage(.Friend_Loading);
        
        Extern.mainVC?.chattingPage.isFriendPage = true;
    }
    
    func onClickInstagram(indexPath: IndexPath) {
        var userId: String? = nil;
        
        if (filteredItems == nil) {
            userId = friendItems [indexPath.row].phoneNumber;
        } else {
            userId = filteredItems? [indexPath.row].phoneNumber;
        }
        if (userId == nil) { return }
        
        Instagram.shared.user(userId!, success: { (user: InstagramUser) in
            self.showInstagramUserInfo(user: user);
        }) { (error: Error) in
            Extern.mainVC?.showMessage(title: "Instagram", content: error.localizedDescription);
        }
    }
    
    func showInstagramUserInfo(user: InstagramUser) {
        let instagramHooks = "instagram://user?username=" + user.username;
        let instagramUrl = URL(string: instagramHooks)
        
        if UIApplication.shared.canOpenURL(instagramUrl!) {
            UIApplication.shared.open(instagramUrl!, options: [:], completionHandler: nil);
        } else {
            let strWebUrl = "https://www.instagram.com/" + user.username;
            let webUrl = URL(string: strWebUrl);
            //redirect to safari because the user doesn't have Instagram
            UIApplication.shared.open(webUrl!, options: [:], completionHandler: nil);
        }
    }
    
    func onItemPressed(indexPath: IndexPath) {
        var friend: Friends;
        if (filteredItems == nil) {
            friend = friendItems [indexPath.row];
        } else {
            friend = (filteredItems? [indexPath.row])!;
        }
        
        if (pinList [friend.phoneNumber!] == nil
            || friend.phoneNumber == selectedFriend?.phoneNumber) { return }
        
        processSelectedItem(friend: friend);
    }
    
    func onLongPressed(indexPath: IndexPath) {
        let title = "What's up?";
        
        let actionCont = UIAlertController(title: title, message: "", preferredStyle: .actionSheet);
        
        let action1 = UIAlertAction(title: "unfriend this person 🙈", style: .default) { (action: UIAlertAction) in
            self.unFriend(indexPath: indexPath);
        }
        let action2 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionCont.addAction(action1);
        actionCont.addAction(action2);
        
        parentVC?.present(actionCont, animated: true, completion: nil);
    }
    
    func unFriend(indexPath: IndexPath) {
        var phoneNumber: String? = nil;
        if (filteredItems == nil) {
            phoneNumber = friendItems [indexPath.row].phoneNumber;
        } else {
            phoneNumber = filteredItems? [indexPath.row].phoneNumber;
        }
        Extern.dbFriends.removeWithPhoneNumber(phoneNumber: phoneNumber!);
        
        onDeactive();
        onActive();
    }
    
    func markOnlineUsers(data: [String: Int]) {
        onlineStatus?.removeAll();
        
        onlineStatus = data;
        
        sortFriendWithOnlineStatus();
        
        tblFriends.reloadData();
        
        DispatchQueue.main.async {
            self.addPins();
        }
    }
    
    func sortFriendWithOnlineStatus() {
        if (onlineStatus == nil) { return }
        if (friendItems == nil) { return }
        if (friendItems.count == 0) { return }
        
        var sortedFriendItems: [Friends] = [Friends]();
        
        let count: Int = friendItems.count;     //(onlineStatus?.count)!;
        
        //Catch online users.
        for index in 0 ..< count {
            let phoneNumber = friendItems [index].phoneNumber!;
            
            if (onlineStatus! [phoneNumber] == nil) { continue; }
            if (onlineStatus! [phoneNumber] == 0) { continue; }     //If offline, skip it.
            sortedFriendItems.append(friendItems [index]);
        }
        
        //Catch offline users.
        for index in 0 ..< count {
            let phoneNumber = friendItems [index].phoneNumber!;
            
            if (onlineStatus! [phoneNumber] == 1) { continue; }     //If online, skip it.
            sortedFriendItems.append(friendItems [index]);
        }
        
        friendItems.removeAll();
        friendItems = sortedFriendItems;
        
        sortedFriendItems.removeAll();
    }
    
    func addPins() {
        self.removePins();
        
        if (friendItems == nil) { return }
        for friend in friendItems {
            let fLat = friend.latitude
            let fLng = friend.longitude
            let status = onlineStatus != nil ? onlineStatus! [friend.phoneNumber!]! != 0 : false;
            if (!status) { continue; }
            
            addPinToMap(phoneNumber: friend.phoneNumber!, lat: CGFloat(fLat), lng: CGFloat(fLng), isOnline: status);
        }
        
        self.processSelectedItem(friend: self.selectedFriend);
        /*addPinToMap(phoneNumber: "1", lat: 0, lng: 0, isOnline: true);
        addPinToMap(phoneNumber: "2", lat: 40.730610, lng: -73.935242, isOnline: true);       //NewYork
        addPinToMap(phoneNumber: "3", lat: 55.751244, lng: 37.618423, isOnline: true);        //Moscow
        addPinToMap(phoneNumber: "4", lat: 35.652832, lng: 139.839478, isOnline: true);       //Tokyo
        addPinToMap(phoneNumber: "5", lat: 33.50972, lng: 126.52194, isOnline: true);*/
    }
    
    func removePins() {
        for pin in pinList {
            pin.value.removeFromSuperview();
        }
        pinList.removeAll();
    }
    
    func addPinToMap(phoneNumber: String, lat: CGFloat, lng: CGFloat, isOnline: Bool) {
        pinList [phoneNumber] = UIImageView(frame: locToPinRect(lat: lat, lng: lng));
        
        if (isOnline) {
            pinList [phoneNumber]?.image = UIImage(named: "pinmark_online");
        } else {
            pinList [phoneNumber]?.image = UIImage(named: "pinmark_online");
        }
        
        mapContainer.addSubview(pinList [phoneNumber]!);
    }
    
    func processSelectedItem(friend: Friends?) {
        if (friend == nil) { return }
        //Clear selected mark.
        let pinImage = UIImage(named: "pinmark_online");
        
        if (selectedFriend != nil
            && selectedFriend?.phoneNumber != nil
            && pinList [selectedFriend!.phoneNumber!] != nil) {
            pinList [selectedFriend!.phoneNumber!]?.removeFromSuperview();
            pinList [selectedFriend!.phoneNumber!] = nil;
            
            addPinToMap(phoneNumber: selectedFriend!.phoneNumber!,
                        lat: CGFloat((selectedFriend?.latitude)!),
                        lng: CGFloat((selectedFriend?.longitude)!),
                        isOnline: true);
            
            selectedFriend = nil;
        }
        
        let newPhoneNumber = friend!.phoneNumber!;
        if (pinList [newPhoneNumber] == nil) {
            selectedFriend = nil;
            return
        }
        
        //Mark Selected friend.
        pinList [newPhoneNumber]?.image = nil;
        pinList [newPhoneNumber]?.removeFromSuperview();
        pinList [newPhoneNumber] = nil;
        
        pinList [newPhoneNumber] = UIImageView(frame: locToMarkRect(lat: CGFloat((friend?.latitude)!), lng: CGFloat((friend?.longitude)!)));
        pinList [newPhoneNumber]?.image = UIImage(named: "pinmark_selected");
        mapContainer.addSubview(pinList [newPhoneNumber]!);
        
        selectedFriend = friend;
    }
    
    func locToPos(lat: CGFloat, lng: CGFloat) -> CGPoint {
        let offsetX: CGFloat = mapContainer.bounds.width / 40;
        let offsetY: CGFloat = mapContainer.bounds.width / 15;
        
        let x = mapContainer.bounds.width / 2 + lng / 195.0 * mapContainer.bounds.width / 2 - offsetX;
        let y = mapContainer.bounds.height / 2 - lat / 80.0 * mapContainer.bounds.height / 2 + offsetY;
        
        return CGPoint(x: x, y: y);
    }
    
    func locToPinRect(lat: CGFloat, lng: CGFloat) -> CGRect {
        let pos = locToPos(lat: lat, lng: lng);
        
        return CGRect(origin: CGPoint(x: pos.x - pinSize / 2, y: pos.y - pinSize / 2), size: CGSize(width: pinSize, height: pinSize));
    }
    
    func locToMarkRect(lat: CGFloat, lng: CGFloat) -> CGRect {
        let pos = locToPos(lat: lat, lng: lng);
        
        let markWidth = mapContainer.bounds.width / 30;
        let markHeight = markWidth * 1.546;
        
        return CGRect(origin: CGPoint(x: pos.x - markWidth / 2, y: pos.y - markHeight), size: CGSize(width: markWidth, height: markHeight));
    }
}

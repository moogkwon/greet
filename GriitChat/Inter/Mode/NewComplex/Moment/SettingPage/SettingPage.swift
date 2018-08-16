//
//  SettingPage.swift
//  GriitChat
//
//  Created by leo on 22/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit

class SettingPage: ViewPage, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var contentView: UIScrollView!
    
    @IBOutlet weak var innerView: GradientView!
    
    @IBOutlet weak var profileView: ProfileViewer!
    
    @IBOutlet weak var photoBack: GradientView!
    
    @IBOutlet weak var imgPhoto: UIImageView!
    
    @IBOutlet weak var lblUserName: UILabel!
    
    @IBOutlet weak var tblHelps: UITableView!
    
    @IBOutlet weak var btnLogout: UIButton!
    
    @IBOutlet weak var tblHelpsHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var cameraVideoBox: UIView!
    
    @IBOutlet weak var cameraPhotoBox: UIView!
    
    @IBOutlet weak var videoProfileHeightConstraint: NSLayoutConstraint!
    
    var imagePickerController: UIImagePickerController? = nil;
    
    var innerHeight: CGFloat = 0;
    
    var helpSecTitles: [String]!;
    var helpItems: [Int: [String]]!;

    override init(frame: CGRect) {
        super.init(frame: frame);
        commonInit();
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        commonInit();
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("SettingPage", owner: self, options: nil);
        addSubview(contentView);
        contentView.frame = self.bounds;
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight];
        
        profileView.layer.cornerRadius = frame.width / 7;
        profileView.clipsToBounds = true;
        profileView.alpha = 1;
        profileView.layer.borderColor = UIColor.white.cgColor;
        profileView.layer.borderWidth = 1;
        
        tblHelps.dataSource = self;
        tblHelps.delegate = self;
        
        helpSecTitles = ["", "Contact", "Community", "Legal note", "Contact"];
        helpItems = [0: ["Get more cups 🥤"],
                     1: ["Help, Customer Support"],
                     2: ["Community Guidelines", "Safety help"],
                     3: ["Privacy Policy", "Terms of Service", "License Agreement"],
                     4: ["Wanna chat?"]];
        
        createGesturePhoto();
        createGestureProfile();

        if (Extern.transMng.userInfo != nil) {
            _ = lblUserName.text = Extern.transMng.userInfo! ["firstName"] as? String;
        }
        
        let itemPressRecognizer = UITapGestureRecognizer(target: self, action: #selector(onItemPress))
        contentView.addGestureRecognizer(itemPressRecognizer)
    }
    
    override func onActive() {
        if (isActive) { return }
        super.onActive();
        
        createProfileViewer();
        
        setProfilePhoto();
    }
    
    override func onDeactive() {
        if (!isActive) { return }
        super.onDeactive();
        profileView.freeState();
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        
        contentView.contentSize = CGSize(width: contentView.frame.width, height:  innerHeight);
        innerView.frame = CGRect(x: 0, y: 0, width: contentView.frame.width, height: innerHeight);
        
        innerView.applyGradient(colours: [UIColor(red: 246.0 / 255.0, green: 246.0 / 255.0, blue: 246.0 / 255.0, alpha: 1), UIColor(red: 234.0 / 255.0, green: 234.0 / 255.0, blue: 234.0 / 255.0, alpha: 1)], direction: .vertical, frame: innerView.bounds);
        
        photoBack.layer.cornerRadius = bounds.width * 0.29 / 2.0;
        photoBack.clipsToBounds = true;
        
        let radius = cameraPhotoBox.bounds.width / 2;
        cameraPhotoBox.layer.cornerRadius = radius;
        cameraPhotoBox.clipsToBounds = true;
        cameraPhotoBox.dropShadow(color: .black, opacity: 0.2, offSet: CGSize(width: 0, height: 3), radius: radius, scale: true)
        
        cameraVideoBox.layer.cornerRadius = radius;
        cameraVideoBox.clipsToBounds = true;
        cameraVideoBox.dropShadow(color: .black, opacity: 0.2, offSet: CGSize(width: 0, height: 3), radius: radius, scale: true)
        
        profileView.resizePlayerLayer(frame: profileView.bounds);
        
        imgPhoto.layer.cornerRadius = bounds.width * 0.29 / 2.0 - 3;
        imgPhoto.clipsToBounds = true;
        imgPhoto.layer.borderWidth = 1;
        imgPhoto.layer.borderColor = UIColor.white.cgColor;
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
        tblHelpsHeightConstraint.constant = tblHelps.contentSize.height;
        innerHeight = innerView.frame.height + tblHelps.contentSize.height + 100;
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return helpItems.count;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (helpItems [section]?.count)!;
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 30))
        let label: UILabel = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.bounds.width - 30, height: 30))

        label.textColor = UIColor.black
        label.text = helpSecTitles [section];
        
        let fontAttributes = [UIFontDescriptor.AttributeName.family: "Apple SD Gothic Neo",
                              UIFontDescriptor.AttributeName.textStyle: "SemiBold",
                              UIFontDescriptor.AttributeName.size: 15] as [UIFontDescriptor.AttributeName : Any];
        label.font = UIFont(descriptor: UIFontDescriptor(fontAttributes: fontAttributes), size: 15);
        view.addSubview(label)
        view.backgroundColor = UIColor.clear;
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "SettingHelpTblCell");
        cell.accessoryType = .disclosureIndicator;
        
        cell.textLabel?.text = helpItems [indexPath.section]?[indexPath.row];
        
        let fontAttributes = [UIFontDescriptor.AttributeName.family: "Apple SD Gothic Neo",
                              UIFontDescriptor.AttributeName.textStyle: "SemiBold",
                              UIFontDescriptor.AttributeName.size: 17] as [UIFontDescriptor.AttributeName : Any];
        cell.textLabel?.font = UIFont(descriptor: UIFontDescriptor(fontAttributes: fontAttributes), size: 17);
        cell.textLabel?.textColor = UIColor(red: 155.0/255.0, green: 155.0/255.0, blue: 155.0/255.0, alpha: 1)
        cell.backgroundColor = UIColor.clear;
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        debugPrint(helpItems [indexPath.section]! [indexPath.row]);
    }
    
    @IBAction func onBtnLogout(_ sender: Any) {
//        Extern.mainVC?.dismiss(animated: true, completion: nil);
        onDeactive();
        
        Extern.transMng.logout();
        self.parentVC?.navigationController?.popToRootViewController(animated: true);
    }
    
    func createProfileViewer() {
        if (Extern.transMng.userInfo == nil) { return }
        
        profileView.freeState();
        let videoPath: String? = Extern.transMng.userInfo! ["videoPath"] as? String;
        if (videoPath != nil) {
            profileView.isBlurEffect = true;
            profileView.createProfileViewer(videoPath: videoPath!);
        }
    }
    
    func createGesturePhoto() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(photoTapped))
        
        photoBack.addGestureRecognizer(tap)
        photoBack.isUserInteractionEnabled = true
        photoBack.isMultipleTouchEnabled = true
    }
    
    func createGestureProfile() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(profileTapped))
        
        profileView.addGestureRecognizer(tap)
        profileView.isUserInteractionEnabled = true
        profileView.isMultipleTouchEnabled = true
    }
    
    @objc func photoTapped() {
        let title = "What's up?"
        let actionCont = UIAlertController(title: title, message: "", preferredStyle: .actionSheet);
        
        let action1 = UIAlertAction(title: "Upload new profile picture", style: .default) { (action: UIAlertAction) in
            self.uploadNewProfilePicture();
        }
        let action2 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionCont.addAction(action1);
        actionCont.addAction(action2);
        
        parentVC?.present(actionCont, animated: true, completion: nil);
    }
    
    @objc func profileTapped() {
        let title = "What's up?"
        let actionCont = UIAlertController(title: title, message: "", preferredStyle: .actionSheet);
        
        let action1 = UIAlertAction(title: "Upload new profile video", style: .default) { (action: UIAlertAction) in
            self.uploadNewProfileVideo();
        }
        let action2 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionCont.addAction(action1);
        actionCont.addAction(action2);
        
        parentVC?.present(actionCont, animated: true, completion: nil);
    }
    
    func setProfilePhoto() {
        if (Extern.transMng.userInfo == nil) { return }
        
        if (Extern.transMng.userInfo? ["photoUrl"] as! String != "") {
            self.imgPhoto.setImage(url: URL(string: Extern.transMng.userInfo? ["photoUrl"] as! String)!, defaultImgName: Assets.Default_User_Image)
        } else {
            self.imgPhoto.image = UIImage(named: Assets.Default_User_Image);
        }
    }
    
    func uploadNewProfilePicture() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = Extern.mainVC;
        
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        
        Extern.mainVC?.imagePickerController =  imagePicker;
        
        parentVC?.present(imagePicker, animated: true, completion: nil);
    }
    
    func uploadNewProfileVideo() {
        Extern.mainVC?.imagePickerController = VideoHelper.startMediaBrowser(delegate: Extern.mainVC!, sourceType: .savedPhotosAlbum)
    }
    
    @objc func onItemPress(tapGestureRecognizer: UITapGestureRecognizer) {
        let touchPoint = tapGestureRecognizer.location(in: tblHelps)
        if let indexPath: IndexPath = tblHelps.indexPathForRow(at: touchPoint) {
            switch(indexPath.section) {
            case 0:
                Extern.mainVC?.showPurchasePage(isShowFilter: false);
                break;
            default:
                break;
            }
            return;
        }
    }
}

//
//  MomentCollectView.swift
//  GriitChat
//
//  Created by leo on 21/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit
import AVKit

class MomentPage: ViewPage, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var lblEmpty1: UIView!
    @IBOutlet weak var lblEmpty2: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var items: [Moments]?;
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        commonInit();
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        commonInit();
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("MomentPage", owner: self, options: nil);
        addSubview(contentView);
        contentView.frame = self.bounds;
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight];
        contentView.backgroundColor = UIColor.clear;
        
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        
        self.collectionView.register(UINib(nibName: "MomentCell", bundle: nil), forCellWithReuseIdentifier: "MomentCell");
        
        let flow = collectionView.collectionViewLayout as! UICollectionViewFlowLayout;
        flow.minimumInteritemSpacing = 0.0;
        flow.minimumLineSpacing = 2.0;
        
        collectionView.layer.borderWidth = 2;
        collectionView.layer.borderColor = UIColor.white.cgColor;
        
        /*
        let photoPath = FileManager.makeTempPath("png");
        
        let image: UIImage = UIImage.base64_2Image(base64Str: Extern.transMng.userInfo! ["photo"] as! String);
        _ = image.saveImage(savePath: photoPath);
        
        let videoPath = UserDefaults.standard.value(forKey: UserKey.Profile_Shared_Key);
        
        Extern.dbMoments.addItem(phoneNumber: "123123", photoPath: photoPath, videoPath: videoPath as! String);*/
    }
    
    override func initState() {
        showCollection(value: false);
    }
    
    override func onActive() {
        if (isActive) { return }
        super.onActive();
        
        Extern.dbMoments.removeOldItems();
        
        items = Extern.dbMoments.getAllItems();
        if (items == nil || items!.count == 0) {
            showCollection(value: false);
        } else {
            showCollection(value: true);
        }
        collectionView.reloadData();
    }
    override func onDeactive() {
        if (!isActive) { return }
        super.onDeactive();
        
        items?.removeAll();
        items = nil;
    }
    
    func showCollection(value: Bool) {
        collectionView.isHidden = !value;
        
        lblEmpty1.isHidden = value;
        lblEmpty2.isHidden = value;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (items == nil) { return 0;}
        return items!.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MomentCell", for: indexPath) as! MomentCell
        
        cell.setMomentImg(imgPath: items! [indexPath.row].photoPath!)
        cell.setRemainHours(createAt: items! [indexPath.row].createdAt);
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.bounds.width / 3.0 - 2;
        let height = bounds.height / bounds.width * width;
        return CGSize(width: width, height: height);
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Extern.mainVC?.momentPlayer.dbItem = items! [indexPath.row]
        Extern.mainVC?.gotoPage(.Moment_Player);
    }
}

//
//  MomentCell.swift
//  GriitChat
//
//  Created by leo on 21/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit

class MomentCell: UICollectionViewCell {

    @IBOutlet weak var imgMoment: UIImageView!
    
    @IBOutlet weak var lblRemainHours: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func initElements() {
//        Bundle.main.loadNibNamed("MomentCell", owner: self, options: nil);
    }
    
    func setMomentImg(imgPath: String) {
        debugPrint(imgPath);
        imgMoment.image = UIImage.load(filePath: imgPath);
    }
    
    func setRemainHours(createAt: TimeInterval) {
        let curInterval = Date().timeIntervalSince1970;
        let remainInterval = createAt + DBMoments.expireDuration - curInterval;
        
        let hours:Int = Int(remainInterval / (60 * 60));
        lblRemainHours.text = String(hours) + " hrs";
    }
}

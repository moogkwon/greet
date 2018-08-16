//
//  FriendTableCell.swift
//  GriitChat
//
//  Created by GoldHorse on 7/23/18.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit

protocol FriendCellDelegate {
    func onClickInstagram(indexPath: IndexPath);
    func onClickVideo(indexPath: IndexPath);
}

class FriendTableCell: UITableViewCell {

    @IBOutlet weak var imgBack: GradientView!
    @IBOutlet weak var imgUser: UIImageView!
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    
    @IBOutlet weak var btnInstagram: UIButton!
    @IBOutlet weak var btnChat: UIButton!
    
    var indexPath: IndexPath!;
    
    var delegate: FriendCellDelegate!;
    
    override func updateConstraints() {
        super.updateConstraints();
        
        let height = bounds.height * 0.8;
        
        imgBack.layer.cornerRadius = height / 2;
        imgUser.layer.cornerRadius = height / 2 - 2;
        
        imgBack.clipsToBounds = true;
        imgUser.clipsToBounds = true;
        
        imgUser.layer.borderColor = UIColor.white.cgColor;
        imgUser.layer.borderWidth = 1;
    }
    
    @IBAction func onBtnInstagram(_ sender: Any) {
        delegate.onClickInstagram(indexPath: indexPath);
    }
    
    @IBAction func onBtnVideo(_ sender: Any) {
        delegate.onClickVideo(indexPath: indexPath);
    }
}

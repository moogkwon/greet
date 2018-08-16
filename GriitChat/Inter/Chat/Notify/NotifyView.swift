//
//  NotifyView.swift
//  GriitChat
//
//  Created by leo on 21/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit

class NotifyView: UIView {

    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var bckView: UIView!
    
    @IBOutlet weak var lblContent: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        initElements();
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        initElements();
    }
    
    func initElements() {
        Bundle.main.loadNibNamed("NotifyView", owner: self, options: nil);
        addSubview(contentView);
        contentView.frame = self.bounds;
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight];
    }
    
    override func layoutSubviews() {
        bckView.applyGradient(colours: [UIColor.dodgerBlue.cgColor,
                                                UIColor(red: 0, green: 205, blue: 255, alpha: 1).cgColor], direction: .vertical, frame: bckView.bounds);
        bckView.alpha = 0.5;
        bckView.layer.cornerRadius = bckView.bounds.height / 2;
        bckView.clipsToBounds = true;
        
        lblContent.layer.cornerRadius = lblContent.bounds.height / 2;
        lblContent.clipsToBounds = true;
    }
    
    func setContent(content: String) {
        lblContent.text = content;
    }
}

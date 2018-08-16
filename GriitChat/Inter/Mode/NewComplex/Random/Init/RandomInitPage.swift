//
//  RandomInitPage.swift
//  GriitChat
//
//  Created by leo on 24/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import Foundation

class RandomInitPage: ViewPage {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var btnFilter: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        commonInit();
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        commonInit();
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("RandomInitPage", owner: self, options: nil);
        addSubview(contentView);
        contentView.frame = self.bounds;
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight];
    }
    
    override func updateConstraints() {
        super.updateConstraints();
    }
    
    override func onActive() {
        if (isActive) { return }
        super.onActive();
        
        Extern.transMng.resetState();
        Extern.mainVC?.camView.setupAVCapture();
        Extern.mainVC?.camView.isHidden = false;
    }
    
    override func onDeactive() {
        if (!isActive) { return }
        super.onDeactive();
        
        /*if (Extern.mainVC?.mainState != .Random_Loading) {
            Extern.mainVC?.camView.stopCamera();
        }
        Extern.mainVC?.camView.isHidden = true;*/
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        
        btnFilter.layer.cornerRadius = btnFilter.bounds.width / 2;
        btnFilter.clipsToBounds = true;
        
        btnFilter.dropShadow(color: UIColor.black, opacity: 0.29, offSet: CGSize(width: 0, height: 2), radius: btnFilter.layer.cornerRadius);
    }
}

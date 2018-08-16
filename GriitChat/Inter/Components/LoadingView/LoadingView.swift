//
//  LoadingView.swift
//  GriitChat
//
//  Created by leo on 18/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit

class LoadingView: UIView {
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var backGradView: GradientView!
    
    @IBOutlet weak var imgGlobe: UIImageView!
    
    @IBOutlet weak var progBack: UICircularProgressRing!
    
    @IBOutlet weak var progReal: UICircularProgressRing!
    
    @IBOutlet weak var lblSecond: UILabel!

    @IBOutlet weak var imgConstTop: NSLayoutConstraint!
    
    @IBOutlet weak var imgConstTrail: NSLayoutConstraint!
    
    @IBOutlet weak var imgConstLead: NSLayoutConstraint!
    
    @IBOutlet weak var imgConstBottom: NSLayoutConstraint!
    
    var isLoadGlobe = false;
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        initElements();
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        initElements();
    }
    
    func initElements() {
        Bundle.main.loadNibNamed("LoadingView", owner: self, options: nil);
        addSubview(contentView);
        
        backgroundColor = UIColor.clear;
        
        contentView.frame = self.bounds;
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight];
        
        backGradView.setBackColors(colors: [UIColor.dodgerBlue.cgColor, UIColor.brightLightBlue.cgColor]);
        backGradView.alpha = 0.8;
        
        //Prog Back
        progBack.minValue = 0;
        progBack.maxValue = 1;
        progBack.outerRingWidth = 0;
        progBack.innerRingWidth = progBack.bounds.width / 20;
        progBack.innerRingColor = UIColor.white
        progBack.fontColor = UIColor.init(white: 1, alpha: 0);
        progBack.alpha = 0.3;
        progBack.startProgress(to: 1, duration: 0);
        
        imgConstTop.constant = progBack.innerRingWidth;
        imgConstBottom.constant = -progBack.innerRingWidth;
        imgConstLead.constant = progBack.innerRingWidth;
        imgConstTrail.constant = -progBack.innerRingWidth;
        
        //Prog Real
        progReal.startAngle = 270;
        progReal.minValue = 0;
        progReal.maxValue = 100;
        progReal.outerRingWidth = 0;
        progReal.innerRingWidth = progReal.bounds.width / 20;
        progReal.innerRingColor = UIColor.white;
        progReal.fontColor = UIColor.init(white: 1, alpha: 0);
        
        progReal.startProgress(to: 0, duration: 0);
        
        //Globe Image
        imgGlobe.isHidden = true;
        lblSecond.isHidden = true;
    }
    
    func setGradBackAlpha(alpha: CGFloat) {
        backGradView.alpha = alpha;
        backGradView.setBackColors(colors: [UIColor.dodgerBlue.cgColor, UIColor.brightLightBlue.cgColor]);
    }
    
    func setProgMaxValue(maxValue: CGFloat) {
        progReal.maxValue = maxValue;
    }
    
    func setProgValue(value: CGFloat, duration: CGFloat) {
        progReal.startProgress(to: value, duration: UICircularProgressRing.ProgressDuration(duration));
    }
    
    func showGlobe(alpha: CGFloat) {
        if (!isLoadGlobe) {
            imgGlobe.loadGif(asset: "globe");
            isLoadGlobe = true;
            
        }
        imgGlobe.isHidden = false;
        imgGlobe.alpha = alpha;
    }

    func showLabel(number: Int) {
        lblSecond.text = String(number);
        lblSecond.isHidden = false;
    }
}

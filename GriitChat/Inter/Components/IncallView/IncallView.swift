//
//  IncallView.swift
//  GriitChat
//
//  Created by leo on 17/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit

protocol IncallViewDelegate {
    func onReceiveCall(phoneNumber: String);
}

class IncallView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var backGradientView: GradientView!
    
    @IBOutlet weak var backWhiteView: UIView!
    
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var progView: UICircularProgressRing!
    
    var delegate: IncallViewDelegate? = nil;
    var phoneNumber: String = "";
    
    var curProgValue: Int = 0;
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override init(frame: CGRect) {
        super.init(frame: frame);
        initElements();
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        initElements();
    }
    
    func initElements() {
        Bundle.main.loadNibNamed("IncallView", owner: self, options: nil);
        addSubview(contentView);
        contentView.frame = self.bounds;
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight];
        
        backGradientView.setBackColors(colors: [UIColor.dodgerBlue.cgColor, UIColor.brightLightBlue.cgColor]);
        
        progView.outerRingWidth = 0;
        progView.fontColor = UIColor(white: 1, alpha: 0);
        progView.innerRingColor = UIColor.brightLightBlue;
        progView.alpha = 0.5;
        progView.minValue = 0;
        progView.maxValue = 1;
        progView.startProgress(to: 1, duration: 0) {}
        self.alpha = 0;
        
        curProgValue = TransMng.COUNT_RINGTONE;
    }
    
    func layout(width: CGFloat) {
        backGradientView.layer.cornerRadius = width / 2;
        backGradientView.clipsToBounds = true;
        
        backWhiteView.layer.cornerRadius = width * 0.95 / 2;
        backWhiteView.clipsToBounds = true;
        
        imgView.layer.cornerRadius = width * 0.95 * 0.95 / 2;
        imgView.clipsToBounds = true;
        
        progView.innerRingWidth = width / 2;
    }
    
    func setImage(base64Data: String) {
        imgView.image = UIImage.base64_2Image(base64Str: base64Data);
        fadeImage();
    }
    
    func setImage(named: String) {
        imgView.image = UIImage(named: named);
        fadeImage();
    }
    
    func setImage(image: UIImage) {
        imgView.image = image;
        fadeImage();
    }
    
    func setImage(url: String) {
        imgView.setImage(url: URL(string: url), defaultImgName: Assets.Default_User_Image);
        fadeImage();
    }
    
    func fadeImage() {
        self.alpha = 0;
        UIView.animate(withDuration: 0.5) {
            self.alpha = 1;
        }
    }
    
    func setProg(curVal: Int, maxVal: Int) {
        let dCurVal: CGFloat = CGFloat(curVal);
        let dMaxVal: CGFloat = CGFloat(maxVal);
        
        curProgValue = curVal;
        
        progView.innerRingWidth = progView.bounds.width / 2.0 * dCurVal / dMaxVal;
    }
    
    
    @IBAction func onBtnReceive(_ sender: Any) {
        if (delegate != nil && phoneNumber != "") {
            self.delegate?.onReceiveCall(phoneNumber: phoneNumber);
        }
    }
}

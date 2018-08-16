//
//  InstagramButton.swift
//  GriitChat
//
//  Created by leo on 20/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit

protocol InstagramBtnDelegate {
    func onClick();
    func onTakePhoto();
    func onRecordStart();
    func onRecordEnd(time: CGFloat);
}

class InstagramButton: UIView {

    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var progBack: SFCircleGradientView!
    
    @IBOutlet weak var progWhiteBack: SFCircleGradientView!
    
    @IBOutlet weak var realProgress: SFCircleGradientView!
    
    @IBOutlet weak var imgInstagram: UIImageView!
    
    @IBOutlet weak var viewDisabled: UIView!
    
    var delegate: InstagramBtnDelegate? = nil;
    
    enum ButtonState {
        case Disabled;
        case Enabled;
    };
    
    var smlImgRect: CGRect! = nil;
    var smlBckRect: CGRect! = nil;
    var smlWhtRect: CGRect! = nil;
    
    var btnState: ButtonState = .Disabled;
    var timer: Timer!;
    
    let totalSeconds: CGFloat = 5.0;
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        initElements();
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        initElements();
    }
    
    func initElements() {
        Bundle.main.loadNibNamed("InstagramButton", owner: self, options: nil);
        addSubview(contentView);
        contentView.frame = self.bounds;
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight];
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        contentView.addGestureRecognizer(tapGestureRecognizer)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        contentView.addGestureRecognizer(longPressRecognizer)
        
        progBack.isUserInteractionEnabled = true
        progBack.isMultipleTouchEnabled = true
        
        progBack.startColor = UIColor.dodgerBlue.withAlphaComponent(0.8);
        progBack.endColor = UIColor.brightLightBlue.withAlphaComponent(0.8);
        progBack.startAngle = -1.57;
        progBack.endAngle = 4.71;
        
        realProgress.startColor = UIColor.dodgerBlue.withAlphaComponent(0.8);
        realProgress.endColor = UIColor.brightLightBlue.withAlphaComponent(0.8);
        realProgress.startAngle = -1.57;
        realProgress.endAngle = -1.57 + 6.28;
        realProgress.setProgress(0, animateWithDuration: 0);
        realProgress.isHidden = true;
        
        
        progBack.clipsToBounds = true;
        progWhiteBack.clipsToBounds = true;
        
        setBtnState(state: .Enabled);
        
        viewDisabled.layer.borderColor = UIColor.white.cgColor;
        viewDisabled.layer.borderWidth = 2;
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        becomeSmallBtn();
        
        viewDisabled.layer.cornerRadius = bounds.width * 0.65 / 2.0;
        viewDisabled.clipsToBounds = true;
        
        contentView.layer.cornerRadius = bounds.width / 2.0;
        contentView.clipsToBounds = true;
    }
    
    @objc func tapped(sender: UILongPressGestureRecognizer)
    {
        if (btnState == .Disabled) {
            delegate?.onClick();
            return;
        }
        
        UIView.animate(withDuration: 0.2, animations: self.becomeBigBtn) { (_: Bool) in
            UIView.animate(withDuration: 0.3, animations: self.becomeSmallBtn);
        }
        delegate?.onTakePhoto();
    }
    
    func becomeBigBtn() {
        if (smlBckRect == nil) {
            smlImgRect = imgInstagram.frame;
            smlBckRect = progBack.frame;
            smlWhtRect = progWhiteBack.frame;
        }
        
        progBack.lineWidth = contentView.bounds.width / 5;
        progWhiteBack.lineWidth = progBack.lineWidth - 4;
        realProgress.lineWidth = contentView.bounds.width / 20;

        progBack.frame = bounds;
        progWhiteBack.frame = CGRect(x: 2, y: 2, width: bounds.width - 4, height: bounds.height - 4);
        let offset: CGFloat = 3.0;
        imgInstagram.frame = CGRect(x: smlImgRect.origin.x + offset,
                                    y: smlImgRect.origin.y + offset,
                                    width: smlImgRect.width - offset * 2,
                                    height: smlImgRect.height - offset * 2)
        
        realProgress.frame = progWhiteBack.frame;
    }
    
    func becomeSmallBtn() {
        progBack.lineWidth = contentView.bounds.width / 13;
        progWhiteBack.lineWidth = progBack.lineWidth - 4;
        
        if (smlBckRect != nil) {
            progBack.frame = smlBckRect;
            progWhiteBack.frame = smlWhtRect;
            imgInstagram.frame = smlImgRect;
        }
    }
    
    var duration: CGFloat = 0.0;
    @objc func longPressed(sender: UILongPressGestureRecognizer)
    {
        if (btnState == .Disabled) { return; }
        if (sender.state != .ended && timer == nil) {
            UIView.animate(withDuration: 0.2, animations: self.becomeBigBtn);
            
            if (timer != nil) {
                timer.invalidate();
                timer = nil;
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                self.realProgress.isHidden = false;
                self.duration = 0.0;
                
                self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: (#selector(self.updateTimer)), userInfo: nil, repeats: true);
            })
            delegate?.onRecordStart();
        } else if (sender.state == .ended) {
            UIView.animate(withDuration: 0.3, animations: self.becomeSmallBtn);
            realProgress.isHidden = true;
            
            if (timer != nil) {
                delegate?.onRecordEnd(time: duration);
                timer.invalidate();
                timer = nil;
            }
            
            self.realProgress.setProgress(0, animateWithDuration: 0);
            self.realProgress.progress = 0;
            self.realProgress.endAngle = -1.57;
            self.realProgress.endAngle = -1.57 + 6.28;
            self.duration = 0.0;
        }
    }
    
    @objc func updateTimer(timer: Timer) {
        duration += 0.1;
        
        if (duration >= totalSeconds) {
            timer.invalidate();
            self.timer = nil;
            delegate?.onRecordEnd(time: duration);
            return;
        }
        debugPrint(duration);
        DispatchQueue.main.async {
            let newValue = self.duration / self.totalSeconds;
            self.realProgress.setProgress(newValue, animateWithDuration: 0.1);
        }
    }

    func setBtnState(state: ButtonState) {
        btnState = state;
        if (btnState == .Disabled) {
            progBack.isHidden = true;
            progWhiteBack.isHidden = true;
            realProgress.isHidden = true;
            imgInstagram.isHidden = true;
            viewDisabled.isHidden = false;
        } else {
            progBack.isHidden = false;
            progWhiteBack.isHidden = false;
            realProgress.isHidden = false;
            imgInstagram.isHidden = false;
            viewDisabled.isHidden = true;
        }
    }
}

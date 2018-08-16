//
//  CupFullView.swift
//  GriitChat
//
//  Created by leo on 24/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit

protocol CupFullViewDelegate {}

class CupFullView: UIView {

    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var gradBack: GradientView!
    
    @IBOutlet weak var innerView: UIView!
    
    @IBOutlet weak var filterView: UIView!
    
    @IBOutlet weak var btnCenterLogo: UIButton!
    
    @IBOutlet weak var lblRemainCupCount: UILabel!
    
    let animationDuration = 0.5;
    
    let cupPriceTable: [Int: Float] = [5: 4.99,
                                       12: 9.99,
                                       25: 19.99,
                                       65: 49.99,
                                       140: 99.99,
                                       330: 199.99];
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        commonInit();
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        commonInit();
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("CupFullView", owner: self, options: nil);
        addSubview(contentView);
        contentView.frame = self.bounds;
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight];
        
        gradBack.applyGradient(colours: [UIColor.dodgerBlue.cgColor,
                                         UIColor.init(red: 0, green: 205.0 / 255.0, blue: 255.0 / 255.0, alpha: 1).cgColor], direction: .vertical, frame: contentView.frame);
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeDown.direction = .down
        self.addGestureRecognizer(swipeDown)
        
        innerView.layer.cornerRadius = frame.width / 9;
        innerView.clipsToBounds = true;
        innerView.layer.borderColor = UIColor.white.cgColor;
        innerView.layer.borderWidth = 1;
        
        btnCenterLogo.setImage(UIImage(named: "cuplogo_active"), for: .selected);
        btnCenterLogo.setImage(UIImage(named: "cuplogo_empty"), for: .normal);
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizerDirection.down {
            dismiss();
        }
    }
    
    func showPresent(isShowFilter: Bool) {
        let top = 0;
        
        let cupCount = Extern.cupManager.getCupCount();
        
        btnCenterLogo.isSelected = cupCount != 0;
        
        filterView.isHidden = !isShowFilter;
        lblRemainCupCount.text = String(format: "%d", cupCount);
        
        self.frame.origin = CGPoint(x: 0, y: bounds.height);
        self.isHidden = false;
        
        UIView.animate(withDuration: animationDuration) {
            self.frame.origin = CGPoint(x: 0, y: top);
            self.alpha = 1;
        }
    }
    
    
    @IBAction func onBtnDismiss(_ sender: Any) {
        dismiss();
    }
    
    func dismiss() {
        let bottom = self.frame.origin.y + self.frame.height;
        UIView.animate(withDuration: animationDuration, animations: {
            self.frame.origin = CGPoint(x: 0, y: bottom);
            self.alpha = 0.5;
        }) { (result: Bool) in
            self.isHidden = true;
        }
    }
    
    static func createView(controller: UIViewController) -> CupFullView {
        let view: UIView = controller.view!;
        
        let newView = CupFullView(frame: CGRect(x: 0, y: view.frame.maxY, width: view.frame.width, height: view.frame.height));
        newView.translatesAutoresizingMaskIntoConstraints = false;
        newView.alpha = 0;
        view.addSubview(newView);
        
        let horzCont = NSLayoutConstraint(item: newView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0);
        let vertCont = NSLayoutConstraint(item: newView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0);
        
        let widthCont = NSLayoutConstraint(item: newView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0);
        let heightCont = NSLayoutConstraint(item: newView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1, constant: 0);
        
        
        view.addConstraints([horzCont, vertCont, widthCont, heightCont]);
        
        newView.backgroundColor = UIColor.clear;
        
        return newView;
    }

    @IBAction func onBtnBuyCup(_ sender: Any) {
        let btnBuy: UIButton = sender as! UIButton;
        let strCupCount: String? = btnBuy.restorationIdentifier;
        if (strCupCount == nil) { return; }
        
        let cupCount: Int = Int(strCupCount!)!;
        let price = cupPriceTable [cupCount];
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            Extern.cupManager.plusCup(cupCount: cupCount);
        }
    }
    
    
    
}

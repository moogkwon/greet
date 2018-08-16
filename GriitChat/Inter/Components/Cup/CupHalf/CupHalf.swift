//
//  CupHalf.swift
//  GriitChat
//
//  Created by leo on 24/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit

class CupHalf: UIView {

    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var gradBack: GradientView!
    
    @IBOutlet weak var innerView: UIView!
    
    @IBOutlet weak var btnFilterEvery: UIButton!
    
    @IBOutlet weak var btnFilterFemale: UIButton!
    
    @IBOutlet weak var btnFilterMale: UIButton!
    
    @IBOutlet weak var progBack: UICircularProgressRing!
    
    @IBOutlet weak var progCircle: UICircularProgressRing!
    
    @IBOutlet weak var cupCountStack: UIStackView!
    
    @IBOutlet weak var lblCupCount: UILabel!
    
    @IBOutlet weak var timeStack: UIStackView!
    
    @IBOutlet weak var lblTimeRemains: UILabel!
    
    @IBOutlet weak var lblCupDescription: UILabel!
    
    let animationDuration = 0.5;
    
    var afterDismiss: (() -> Void)? = nil;
    
    var isShowSelf = false;
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        commonInit();
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        commonInit();
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("CupHalf", owner: self, options: nil);
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
        
        
        let progWidth = bounds.width * 0.0125;
        
        //Prog Back
        progBack.minValue = 0;
        progBack.maxValue = 1;
        progBack.outerRingWidth = 0;
        progBack.innerRingWidth = progWidth;
        progBack.innerRingColor = UIColor.white
        progBack.fontColor = UIColor.init(white: 1, alpha: 0);
        progBack.alpha = 0.3;
        progBack.startProgress(to: 1, duration: 0);
        
        //Prog Real
        progCircle.startAngle = 270;
        progCircle.minValue = 0;
        progCircle.maxValue = CGFloat(CupManager.TotalFunTime);
        progCircle.outerRingWidth = 0;
        progCircle.innerRingWidth = progWidth;
        progCircle.innerRingColor = UIColor.white;
        progCircle.fontColor = UIColor.init(white: 1, alpha: 0);
        progCircle.startProgress(to: CGFloat(Extern.cupManager.getCupRemainDuration()), duration: 1);
        
        
        btnFilterEvery.setImage(UIImage(named: "btnEveryone_gray"), for: .normal);
        btnFilterFemale.setImage(UIImage(named: "btnFemale_gray"), for: .normal);
        btnFilterMale.setImage(UIImage(named: "btnMale_gray"), for: .normal);
        
        btnFilterEvery.setImage(UIImage(named: "btnEveryone_active"), for: .selected);
        btnFilterFemale.setImage(UIImage(named: "btnFemale_active"), for: .selected);
        btnFilterMale.setImage(UIImage(named: "btnMale_active"), for: .selected);
        
        btnFilterEvery.setImage(UIImage(named: "btnEveryone_active"), for: .disabled);
        
        isShowSelf = true;
        refreshView();
        isShowSelf = false;
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizerDirection.down {
            dismiss();
        }
    }
    
    func showPresent(_ completion: (() -> Void)? = nil) {
        self.isHidden = false;
        refreshView();
        self.afterDismiss = completion;
        self.frame.origin = CGPoint(x: 0, y: bounds.height);
        
        UIView.animate(withDuration: animationDuration) {
            self.frame.origin = CGPoint(x: 0, y: 0);
            self.alpha = 1;
            self.isShowSelf = true;
        }
    }
    
    @IBAction func onBtnDismiss(_ sender: Any) {
        dismiss(self.afterDismiss);
    }
    
    @IBAction func onBtnCupUse(_ sender: Any) {
        if (Extern.cupManager.isUsingCup()) { return }
        
        //If user has Zero cup, it shows purchasing page.
        if (Extern.cupManager.getCupCount() == 0) {
            dismiss({() in
                Extern.mainVC?.showPurchasePage(isShowFilter: true);
            });
            return;
        }
        
        Extern.cupManager.startUseCup();
    }
    
    func dismiss(_ completion: (()->Void)? = nil) {
        let bottom = bounds.height
        UIView.animate(withDuration: animationDuration, animations: {
            self.frame.origin = CGPoint(x: 0, y: bottom);
            self.alpha = 0.5;
        }) { (result: Bool) in
            self.isHidden = true;
            self.isShowSelf = false;
            completion?();
        }
    }
    
    func refreshView() {
        if (!isShowSelf) { return }
        
        let isUsingCup = Extern.cupManager.isUsingCup();
        btnFilterEvery.isEnabled = isUsingCup;
        btnFilterFemale.isEnabled = isUsingCup;
        btnFilterMale.isEnabled = isUsingCup;
        
        deactiveAllFilters();
        
        if (isUsingCup) {
            switch (Extern.cupManager.filterMode) {
            case .Everyone:
                btnFilterEvery.isSelected = true;
                break;
            case .Female:
                btnFilterFemale.isSelected = true;
                break;
            case .Male:
                btnFilterMale.isSelected = true;
                break;
            }
        }
        
        timeStack.isHidden = !isUsingCup;
        cupCountStack.isHidden = isUsingCup;
        lblCupDescription.isHidden = isUsingCup;
        
        lblCupCount.text = String(format: "%d", Extern.cupManager.getCupCount());
        lblTimeRemains.text = String(format: "%d", Extern.cupManager.getCupRemainDurationWithInt());
        
        progBack.isHidden = !isUsingCup;
        progCircle.isHidden = !isUsingCup;
        
        let progWidth = bounds.width * 0.0125;
        progBack.innerRingWidth = progWidth;
        progCircle.innerRingWidth = progWidth;
        progCircle.startProgress(to: CGFloat(Extern.cupManager.getCupRemainDuration()), duration: 1);
    }
    
    @IBAction func onBtnEvery(_ sender: Any) {
        if (Extern.cupManager.filterMode == .Everyone) { return }
        
        deactiveAllFilters();
        btnFilterEvery.isSelected = true;
        Extern.cupManager.filterMode = .Everyone;
    }
    
    @IBAction func onBtnFemale(_ sender: Any) {
        if (Extern.cupManager.filterMode == .Female) { return }
        
        deactiveAllFilters();
        btnFilterFemale.isSelected = true;
        Extern.cupManager.filterMode = .Female;
    }
    
    @IBAction func onBtnMale(_ sender: Any) {
        if (Extern.cupManager.filterMode == .Male) { return }
        
        deactiveAllFilters();
        btnFilterMale.isSelected = true;
        Extern.cupManager.filterMode = .Male;
    }
    
    func deactiveAllFilters() {
        btnFilterEvery.isSelected = false;
        btnFilterFemale.isSelected = false;
        btnFilterMale.isSelected = false;
    }
    
    static func createView(controller: UIViewController) -> CupHalf {
        let view: UIView = controller.view!;
        
        let height = view.frame.height;
        let newView = CupHalf(frame: CGRect(x: 0, y: view.bounds.height, width: view.frame.width, height: height));
        newView.translatesAutoresizingMaskIntoConstraints = false;
        newView.alpha = 0;
        view.addSubview(newView);
        
        let horzCont = NSLayoutConstraint(item: newView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0);
        let bottomCont = NSLayoutConstraint(item: newView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0);
        
        let widthCont = NSLayoutConstraint(item: newView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0);
        let heightCont = NSLayoutConstraint(item: newView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1, constant: 0);
        
        
        view.addConstraints([horzCont, bottomCont, widthCont, heightCont]);
        
        newView.backgroundColor = UIColor.clear;
        
        return newView;
    }
    
}

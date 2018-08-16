//
//  ToolbarView.swift
//  GriitChat
//
//  Created by leo on 15/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit

protocol ToolbarDelegate {
    func onBtnFriend();
    func onBtnSelective();
    func onBtnRandom();
    func onBtnMoment();
}


enum ToolbarSlideDirection {
    case Up;
    case Down;
}

class ToolbarView: UIView {
    enum TabName: String {
        case Friend = "FriendViewController";
        case Selective = "SelectiveLoadingViewController";
        case Random = "RandomViewController";
        case Moment = "MomentviewController";
    }
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var btnFriend: UIButton!
    
    @IBOutlet weak var btnSelective: UIButton!
    
    @IBOutlet weak var btnRandom: UIButton!
    
    @IBOutlet weak var btnMoment: UIButton!
    
    var tabButtons: [TabName: UIButton]! = nil;
    
    var delegate: ToolbarDelegate? = nil;
    var parent: UIViewController? = nil;
    var isTransparent: Bool = true;
    var bottomBorder: UIView? = nil;
    
    var curTabName: TabName? = nil;
    
    var orgRect: CGRect? = nil;
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        commonInit();
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        commonInit();
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("Toolbar", owner: self, options: nil);
        addSubview(contentView);
        contentView.frame = self.bounds;
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight];
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    @IBAction func onBtnFriend(_ sender: Any) {
        if (delegate != nil) {
            delegate?.onBtnFriend();
            return;
        }
        if (parent != nil) {
            showController(controllerName: .Friend);
        }
    }
    
    @IBAction func onBtnSelective(_ sender: Any) {
        if (delegate != nil) {
            delegate?.onBtnSelective();
            return;
        }
        if (parent != nil) {
            showController(controllerName: .Selective);
        }
    }
    
    @IBAction func onBtnRandom(_ sender: Any) {
        if (delegate != nil) {
            delegate?.onBtnFriend();
            return;
        }
        if (parent != nil) {
            showController(controllerName: .Random);
        }
    }
    
    @IBAction func onBtnMoment(_ sender: Any) {
        if (delegate != nil) {
            delegate?.onBtnMoment();
            return;
        }
        if (parent != nil) {
            showController(controllerName: .Moment);
        }
    }
    
    static func createToolbarView(controller: UIViewController) -> ToolbarView {
        let view: UIView = controller.view!;
        
        let sToolbarView = ToolbarView(frame: view.bounds);
        sToolbarView.translatesAutoresizingMaskIntoConstraints = false;
        view.addSubview(sToolbarView);
        
        let horzCont = NSLayoutConstraint(item: sToolbarView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0);
        let bottomCont = NSLayoutConstraint(item: sToolbarView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0);
        
        let widthCont = NSLayoutConstraint(item: sToolbarView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0);
        let heightCont = NSLayoutConstraint(item: sToolbarView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 0.06, constant: 0);
        
        
        view.addConstraints([horzCont, bottomCont, widthCont, heightCont]);
        
        sToolbarView.isTransparent = true;
        sToolbarView.parent = controller;
        sToolbarView.backgroundColor = UIColor.clear;
        
        return sToolbarView;
    }
    /*
    func animateToolbarView() {
        center.y = (parent?.view.bounds.height)! + bounds.height / 2;
        
        UIView.animate(withDuration: 1) {
            self.center.y = (self.parent?.view.bounds.height)! - self.bounds.height / 2;
        }
    }*/
    
    func showController(controllerName: TabName) {
        orgRect = self.frame
        
        Extern.transMng.resetState();
        Extern.mainVC?.sLoadingPage.requestState = .BeforeRequest;
        
        switch (controllerName) {
        case .Selective:
            Extern.mainVC?.gotoPage(.Selective_Loading);
            break;
            
        case .Random:
            Extern.mainVC?.gotoPage(.Random_Init);
            break;
            
        case .Friend:
            Extern.mainVC?.gotoPage(.Friend_Main);
            break;
            
        case .Moment:
            Extern.mainVC?.gotoPage(.Moment_Main);
            break;
        }
        setActive(tabName: controllerName);
    }
    
    func setStyle(button: UIButton) {
    }
    
    func unsetActiveTabs() {
        let buttons = [btnFriend, btnSelective, btnRandom, btnMoment];
        
        let buttonNames = ["friends_gray", "selective_gray", "random_gray", "moment_gray"];
        
        for i in 0 ..< buttons.count {
            let button: UIButton = buttons [i]!;
            
            button.layer.cornerRadius = 0;
            button.clipsToBounds = true;
            button.backgroundColor = UIColor.clear;
            button.alpha = 1;
            button.setImage(UIImage(named: buttonNames [i]), for: .normal);
            button.isUserInteractionEnabled = true;
        }
        if (bottomBorder != nil) {
            bottomBorder?.removeFromSuperview();
            bottomBorder = nil;
        }
    }
    
    func setActive(tabName: TabName) {
        if (tabButtons == nil) {
            tabButtons = [TabName.Friend: btnFriend,
                          TabName.Selective: btnSelective,
                          TabName.Random: btnRandom,
                          TabName.Moment: btnMoment];
        }
        
        if (tabButtons [tabName] == nil) {
            return;
        }
        
        curTabName = tabName;
        
        unsetActiveTabs();
        layoutSubviews();
        setActiveImages();
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        
        let button: UIButton! = tabButtons [curTabName!];
        
        if (curTabName == .Selective || curTabName == .Random) {
            isTransparent = true;
        } else {
            isTransparent = false;
        }
        
        if (isTransparent) {
            button.layer.cornerRadius = button.bounds.height / 2;
            button.clipsToBounds = true;
            button.backgroundColor = UIColor.white;
            button.alpha = 0.8;
            
            self.backgroundColor = UIColor.clear;
            setShadow(isShadow: true);
        } else {
            if (bottomBorder != nil) {
                bottomBorder?.removeFromSuperview();
                bottomBorder = nil;
            }
            
            bottomBorder = UIView(frame: CGRect(x: 0, y: button.bounds.height - 1, width: button.bounds.width, height: 1));
            bottomBorder?.backgroundColor = UIColor.brightLightBlue;
            button.addSubview(bottomBorder!);
            
//            self.backgroundColor = UIColor.white;
            setShadow(isShadow: false);
        }
    }
    
    func setActiveImages() {
        if (tabButtons [curTabName!] == nil) {
            return;
        }
        
        let button: UIButton! = tabButtons [curTabName!];
        
        let buttonNames: [TabName: String] = [TabName.Friend: "friends",
                                              TabName.Selective: "selective",
                                              TabName.Random: "random",
                                              TabName.Moment: "moment"];
        
        button.setImage(UIImage(named: buttonNames [curTabName!]!), for: .normal);
        button.isUserInteractionEnabled = false;
    }
    
    func slideToolbar(centerX: CGFloat, direction: ToolbarSlideDirection) {
        return;
        var ratio = abs(centerX) / bounds.width;
        if (direction == .Up) {
            ratio = 1.0 - ratio;
        }
        DispatchQueue.main.async {
            self.center.y = (self.parent?.view.bounds.height)! - self.bounds.height / 2 + self.bounds.height * ratio;
        }
    }
    
    func slideToolbar(ratio: CGFloat, direction: ToolbarSlideDirection) {
        var newRatio = abs(ratio);
        if (direction == .Up) {
            newRatio = 1.0 - abs(ratio);
        }
        
        if (ratio == 1 && direction == .Down) {
            self.isHidden = true;
        } else {
            self.isHidden = false;
        }
        
        let window = UIApplication.shared.keyWindow
        let topPadding = window?.safeAreaInsets.top
//        let bottomPadding = window?.safeAreaInsets.bottom
        
        let offsetY: CGFloat = (topPadding! + (orgRect?.height)!) * newRatio;
        
        UIView.animate(withDuration: 0.1, animations: {
            Extern.mainVC?.toolbarBottomConst.constant = offsetY;
        });
    }
    
    func setShadow(isShadow: Bool) {
        if (tabButtons [curTabName!] == nil) {
            return;
        }
        
        for button in tabButtons {
            //Unshadow...
            button.value.dropShadow(color: UIColor.black, opacity: 0, offSet: CGSize(width: 0, height: 2));
        }
        
        if (isShadow) {
            tabButtons [curTabName!]?.dropShadow(color: UIColor.black, opacity: 0.29, offSet: CGSize(width: 0, height: 2), radius: (tabButtons [curTabName!]?.bounds.height)! / 2);
        }
    }
}

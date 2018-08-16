//
//  IncomingList.swift
//  GriitChat
//
//  Created by GoldHorse on 7/26/18.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit

class IncomingList: UIView {

    var viewList : [String: IncallView] = [String: IncallView]();
    
    static let maxViewCount: CGFloat = 3;
    static let paddingRatio_Width: CGFloat = 0.4;
    static let ratioLeft: CGFloat = 0.05;
    static let ratioTop: CGFloat = 0.3;
    static let ratioWidth: CGFloat = 0.11;
    
    static func getEstimateRect(frame: CGRect) -> CGRect {
        let left = frame.width * ratioLeft;
        let top = frame.height * ratioTop;
        let width = frame.width * ratioWidth;
        let height = width * maxViewCount + paddingRatio_Width * width * (maxViewCount - 1);
        
        return CGRect(x: left, y: top, width: width, height: height);
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        commonInit();
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        commonInit();
    }
    
    func commonInit() {
        
    }
    
    func addView(phoneNumber: String, view: IncallView) -> Bool {
        let count = viewList.count;
        if (count >= Int(IncomingList.maxViewCount)) { return false; }
        
        view.frame = getViewRect(index: count);
        viewList [phoneNumber] = view;
        addSubview(view);
        
        return true;
    }
    
    func getViewRect(index: Int) -> CGRect {
        let width = frame.width;
        var top = width * CGFloat(index);
        if (index > 0) {
            top = top + width * CGFloat(index) * IncomingList.paddingRatio_Width;
        }
        
        return CGRect(x: 0, y: top, width: width, height: width);
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        
        for phoneNumber in viewList.keys {
            let view = viewList [phoneNumber]
            var index = 0;
            for otherNumber in viewList.keys {
                if (phoneNumber == otherNumber) { continue; }
                if ((view?.curProgValue)! > (viewList [otherNumber]?.curProgValue)!) {
                    index = index + 1;
                }
            }
            
            view?.frame = getViewRect(index: index);
            view?.updateConstraints()
            view?.layoutSubviews()
        }
    }
}

//
//  CameraContainerView.swift
//  GriitChat
//
//  Created by leo on 06/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit

class CameraContainerView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override func layoutSubviews() {
        for subview in self.subviews {
            subview.frame = self.bounds;
        }
    }

}

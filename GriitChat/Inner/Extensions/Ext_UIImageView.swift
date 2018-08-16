//
//  Ext_UIImageView.swift
//  GriitChat
//
//  Created by GoldHorse on 8/8/18.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit

extension UIImageView {
    func setImage(url: URL?, defaultImgName: String?) {
        var isUrlImgSet = false;
        if (defaultImgName != nil) {
            DispatchQueue.main.async {
                if (!isUrlImgSet) {
                    self.image = UIImage(named: defaultImgName!);
                }
            }
        }
        if (url == nil) { return }
        
        UIImage.downloadImageFromUrl(url: url!, completion: { (img: UIImage?) in
            DispatchQueue.main.async {
                isUrlImgSet = true;
                self.image = img;
            }
        })
    }
}

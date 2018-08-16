//
//  ViewPage.swift
//  GriitChat
//
//  Created by GoldHorse on 7/25/18.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit

class ViewPage: UIView {
    
    var pageName = "ViewPage";
    
    var parentVC: UIViewController? = nil;
    
    var isActive: Bool = false;
    
    func initState() {
        
    }
    
//    func freeState() {}
    
    //Called when shows
    func onActive() {
        isActive = true;
    }
    
    //Called when unshows
    func onDeactive() {
        isActive = false;
    }
}

//
//  RandomChatViewer.swift
//  GriitChat
//
//  Created by GoldHorse on 7/25/18.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit

class RandomChatViewer: MainChatViewer {

    override init(frame: CGRect) {
        super.init(frame: frame);
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    /*override func commonInit() {
        super.commonInit();
        
        Extern.transMng.randomDelegate = self;
        
        afterChatCompletion = {(result: Bool) -> Void in
            Extern.mainVC?.endCallAndStartLoad();
        }
    }
    
    func onStartRandomResponse(result: Int, data: Dictionary<String, Any>) {
        if (result == -1) {
            //Failed.
            Extern.mainVC?.showMessage(title: "Random Mode", content: data ["message"] as! String, completion: {
                self.afterChatCompletion?(false);
            });
        }
    }*/
    
}

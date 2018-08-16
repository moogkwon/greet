//
//  MomentPlayer.swift
//  GriitChat
//
//  Created by leo on 28/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit

class MomentPlayer: ViewPage {

    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var profileViewer: ProfileViewer!
    
    var dbItem: Moments? = nil;
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        commonInit();
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        commonInit();
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("MomentPlayer", owner: self, options: nil);
        addSubview(contentView);
        contentView.frame = self.bounds;
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight];
    }
    
    override func onActive() {
        if (isActive) { return }
        super.onActive();
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews();
        
        profileViewer.freeState();
        
        if (isActive) {
            profileViewer.createProfileViewer(videoPath: (dbItem?.videoPath)!);

            profileViewer.resizePlayerLayer(frame: profileViewer.bounds);
//            profileViewer.avPlayerLayer.frame = profileViewer.bounds;
        }
    }
    
    override func onDeactive() {
        if (!isActive) { return }
        super.onDeactive();
        
        profileViewer.freeState();
    }
    
    @IBAction func onBtnBack(_ sender: Any) {
        Extern.mainVC?.mainPager.scrollToIndex(index: 0, duration: 0.5, completion: {
            Extern.mainVC?.onShowPage(.Moment_Main);
        })
    }
    
    @IBAction func onBtnDot(_ sender: Any) {
        let title = "The screen shots will disappear in 11 hours";
        
        let actionCont = UIAlertController(title: title, message: "", preferredStyle: .actionSheet);
        
        let action1 = UIAlertAction(title: "Delete 🗑", style: .destructive) { (action: UIAlertAction) in
            Extern.dbMoments.removeItem(dbItem: self.dbItem!);
            
            Extern.mainVC?.mainPager.scrollToIndex(index: 0, duration: 0.5, completion: {
                Extern.mainVC?.onShowPage(.Moment_Main);
            })
        }
        let action2 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionCont.addAction(action1);
        actionCont.addAction(action2);
        
        parentVC?.present(actionCont, animated: true, completion: nil);
    }
}

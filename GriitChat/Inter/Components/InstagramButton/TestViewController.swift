//
//  TestViewController.swift
//  GriitChat
//
//  Created by leo on 20/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    @IBOutlet weak var btnInstagram: InstagramButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        
        btnInstagram.addGestureRecognizer(tapGestureRecognizer)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        btnInstagram.addGestureRecognizer(longPressRecognizer)
        
        btnInstagram.isUserInteractionEnabled = true
        btnInstagram.isMultipleTouchEnabled = true*/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func tapped(sender: UILongPressGestureRecognizer)
    {
        debugPrint("AAA Tap Pressed");
        
        if (sender.state == .ended) {
            debugPrint("Tap End!!")
        }
    }
    
    @objc func longPressed(sender: UILongPressGestureRecognizer)
    {
        debugPrint("AAA Long Pressed");
        
        if (sender.state == .ended) {
            debugPrint("Long End!!")
        }
    }

}

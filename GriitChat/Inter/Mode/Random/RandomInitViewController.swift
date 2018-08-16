//
//  RandomViewController.swift
//  GriitChat
//
//  Created by leo on 15/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit

class RandomInitViewController: CalleeViewController {
    
    @IBOutlet weak var btnFilter: UIButton!
    
    var parentController: UIViewController!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
//        sToolbarView.setActive(tabName: .Random);
        btnFilter.layer.cornerRadius = btnFilter.bounds.width / 2;
        btnFilter.clipsToBounds = true;
    }
}

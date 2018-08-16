//
//  CountryViewController.swift
//  GriitChat
//
//  Created by leo on 13/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit

class CountryViewController: UIViewController, CountryListDelegate {
    func selectedCountry(country: Country) {
        print(country.name)
        print(country.flag)
        print(country.countryCode)
        print(country.phoneExtension)
    }
    
    var countryList = CountryList()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let backView: GradientView = super.view as! GradientView;
        backView.setBackColors(colors: [UIColor.dodgerBlue.cgColor, UIColor.brightLightBlue.cgColor]);
        
        title = "Login griit";
        
        
        countryList.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//
//  CountryListTableViewController.swift
//  CountryListExample
//
//  Created by Juan Pablo on 9/8/17.
//  Copyright © 2017 Juan Pablo Fernandez. All rights reserved.
//

import UIKit

public protocol CountryListDelegate: class {
    func selectedCountry(country: Country)
}

public class CountryList: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView: UITableView!
    var resultsController = UITableViewController()
    var filteredCountries = [Country]()
    
    open weak var delegate: CountryListDelegate?
    
    private var countryList: [Country] {
        let countries = Countries()
        let countryList = countries.countries
        return countryList
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Login griit"
        self.view.backgroundColor = .white
        
        tableView = UITableView(frame: view.frame)
        tableView.register(CountryCell.self, forCellReuseIdentifier: "Cell")
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.clear
        
        self.view.addSubview(tableView)
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! CountryCell
        let country = cell.country!
        
        self.delegate?.selectedCountry(country: country)
        
        tableView.deselectRow(at: indexPath, animated: true)
        self.tableView.reloadData()
        
        self.navigationController?.popViewController(animated: true)
        //self.dismiss(animated: true, completion: nil)
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return countryList.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath) as! CountryCell
        
        cell.country = countryList[indexPath.row]
        return cell
    }
}

//
//  DBHistory.swift
//  GriitChat
//
//  Created by leo on 22/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import Foundation
import CoreData

class DBHistory: Database {
    required init() {
        super.init(dbName: "History");
    }
    
    func addItem(firstName: String, phoneNumber: String, instagramName: String, countryCode: String, location: String, photoUrl: String) {
        let item = NSManagedObject(entity: entity, insertInto: managedContext);
        item.setValue(firstName, forKey: "firstName");
        item.setValue(phoneNumber, forKey: "phoneNumber");
        item.setValue(instagramName, forKey: "instagramName");
        item.setValue(countryCode, forKey: "countryCode")
        item.setValue(location, forKey: "location")
        item.setValue(photoUrl, forKey: "photoUrl")
        item.setValue(getCurrentDateTime(), forKey: "createdAt")
        
        save();
    }
    
    func getAllItems() -> [History] {
        return super.getAllItems() as! [History]
    }
}

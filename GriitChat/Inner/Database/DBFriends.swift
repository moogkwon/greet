//
//  DBFriends.swift
//  GriitChat
//
//  Created by leo on 22/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import Foundation
import CoreData

class DBFriends: Database {    
    required init() {
        super.init(dbName: "Friends");
    }
    
    func addItem(firstName: String,
                 phoneNumber: String,
                 instagramName: String,
                 countryCode: String,
                 country: String,
                 location_lat: Float,
                 location_lng: Float,
                 photoUrl: String) {
        
        
        let item = NSManagedObject(entity: entity, insertInto: managedContext);
        item.setValue(firstName, forKey: "firstName");
        item.setValue(phoneNumber, forKey: "phoneNumber");
        item.setValue(instagramName, forKey: "instagramName");
        item.setValue(countryCode, forKey: "countryCode")
        item.setValue(country, forKey: "country")
        item.setValue(location_lat, forKey: "latitude")
        item.setValue(location_lng, forKey: "longitude")
        item.setValue(photoUrl, forKey: "photoUrl")
        item.setValue(getCurrentDateTime(), forKey: "createdAt")
        
        save();
    }
    
    func getAllItems() -> [Friends] {
        return super.getAllItems() as! [Friends]
    }
    
    //true : friend exist.
    //false: friend not exist
    func checkWithPhoneNumber(phoneNumber: String) -> Bool {
        let itemFetch = NSFetchRequest<NSFetchRequestResult>(entityName: dbName);
        
        itemFetch.predicate = NSPredicate(format: "phoneNumber == %@", phoneNumber);
        
        let items: [Friends] = try! managedContext.fetch(itemFetch) as! [Friends];
        return items.count != 0;
    }
    
    func removeWithPhoneNumber(phoneNumber: String) {
        let itemFetch = NSFetchRequest<NSFetchRequestResult>(entityName: dbName);
        
        itemFetch.predicate = NSPredicate(format: "phoneNumber == %@", phoneNumber);
        
        let items: [NSManagedObject] = try! managedContext.fetch(itemFetch) as! [NSManagedObject];
        if (items.count == 0) { return }

        for item in items {
            managedContext.delete(item);
        }
        save();
    }
}

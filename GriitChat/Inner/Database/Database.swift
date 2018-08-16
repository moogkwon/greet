//
//  File.swift
//  GriitChat
//
//  Created by leo on 22/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import Foundation
import CoreData

class Database: NSObject {
    var dbName = "";
    var managedContext: NSManagedObjectContext!;
    var entity: NSEntityDescription!;
    
    init(dbName: String) {
        if (dbName == "") { return }
        
        self.dbName = dbName;
        guard let appDelegate: AppDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        managedContext = appDelegate.persistentContainer.viewContext
        
        entity = NSEntityDescription.entity(forEntityName: dbName, in: managedContext)!
    }
    
    func save() {
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func getCurrentDateTime() -> TimeInterval {
        let date = Date()
        return date.timeIntervalSince1970;
    }
    
    func getAllItems(isSortByDate: Bool = true) -> [NSFetchRequestResult] {
        let itemFetch = NSFetchRequest<NSFetchRequestResult>(entityName: dbName);
        if (isSortByDate) {
            itemFetch.sortDescriptors = [NSSortDescriptor.init(key: "createdAt", ascending: false)]
        }
        
        return try! managedContext.fetch(itemFetch)
    }
}

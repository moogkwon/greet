//
//  DBMoments.swift
//  GriitChat
//
//  Created by leo on 22/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import Foundation
import CoreData

class DBMoments: Database {
    static let expireDuration: TimeInterval = 11 * 60 * 60;
    
    required init() {
        super.init(dbName: "Moments");
    }
    
    func addItem(phoneNumber: String, photoPath: String, videoPath: String) {
        let item = NSManagedObject(entity: entity, insertInto: managedContext);
        item.setValue(phoneNumber, forKey: "phoneNumber");
        item.setValue(photoPath, forKey: "photoPath");
        item.setValue(videoPath, forKey: "videoPath");
        item.setValue(getCurrentDateTime(), forKey: "createdAt")
        
        save();
    }
    
    func getAllItems() -> [Moments] {
        return super.getAllItems() as! [Moments]
    }
    
    func removeOldItems() {
        let curInterval = Date().timeIntervalSince1970;
        
        let items: [Moments] = getAllItems();
        for item in items {
            if (Double(item.createdAt) + DBMoments.expireDuration < curInterval) {
                removeItem(dbItem: item)
            }
        }
        save();
    }
    
    func removeAllItems() {
        let items = getAllItems();
        for item in items {
            removeItem(dbItem: item as! Moments)
        }
        save();
    }
    
    func removeItem(dbItem: Moments) {
        FileManager.deleteFile(filePath: dbItem.photoPath!);
        FileManager.deleteFile(filePath: dbItem.videoPath!);
        
        managedContext.delete(dbItem as! NSManagedObject);
    }
}

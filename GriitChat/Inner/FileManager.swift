//
//  FileManager.swift
//  GriitChat
//
//  Created by leo on 24/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import Foundation

extension FileManager {
    static func deleteFile(filePath: String) {
        let url = URL.init(fileURLWithPath: filePath);
        let fm = FileManager.default;
        let exist: Bool = fm.fileExists(atPath: url.path);
        if (exist) {
            do {
                try fm.removeItem(at: url);
                //                debugPrint("file delected");
            } catch let err {
                debugPrint("file remove error, ", err.localizedDescription);
                return;
            }
        } else {
            //            debugPrint("No file by that name");
        }
    }
    
    static func fileSize(forURL url: Any) -> Double {
        var fileURL: URL?
        var fileSize: Double = 0.0
        if (url is URL) || (url is String)
        {
            if (url is URL) {
                fileURL = url as? URL
            }
            else {
                fileURL = URL(fileURLWithPath: url as! String)
            }
            var fileSizeValue = 0.0
            try? fileSizeValue = (fileURL?.resourceValues(forKeys: [URLResourceKey.fileSizeKey]).allValues.first?.value as! Double?)!
            
            fileSize = fileSizeValue;
            /*if fileSizeValue > 0.0 {
             fileSize = (Double(fileSizeValue) / (1024 * 1024))
             }*/
        }
        return fileSize
    }
    
    static func makeTempUrl(_ ext: String) -> URL {
        return URL(fileURLWithPath: makeTempPath(ext));
    }
    
    static func makeTempPath(_ ext: String) -> String {
        let fileName = String(format: "%d", Int(Date().timeIntervalSince1970)) + "." + ext;
        return NSTemporaryDirectory().appending(fileName);
        /*
         let temp: String = NSTemporaryDirectory();
         debugPrint(temp);
         
         let path: String = FileManager.default.currentDirectoryPath;
         debugPrint(path);
         
         let directory: URL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false);
         
         debugPrint(directory);
         
         debugPrint(directory.absoluteString);
         
         debugPrint(directory.path);*/
        
        /*
         file:///Users/leo/Library/Developer/CoreSimulator/Devices/5136EA20-128F-419E-8E29-1F23D4783A69/data/Containers/Data/Application/1FB6B6C8-0674-4C0D-8D2E-6A375F4EB224/Documents/
         "file:///Users/leo/Library/Developer/CoreSimulator/Devices/5136EA20-128F-419E-8E29-1F23D4783A69/data/Containers/Data/Application/1FB6B6C8-0674-4C0D-8D2E-6A375F4EB224/Documents/"
         "/Users/leo/Library/Developer/CoreSimulator/Devices/5136EA20-128F-419E-8E29-1F23D4783A69/data/Containers/Data/Application/1FB6B6C8-0674-4C0D-8D2E-6A375F4EB224/Documents"
         */
        //       return "";
        
        /*        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
         return ""
         }*/
    }
}

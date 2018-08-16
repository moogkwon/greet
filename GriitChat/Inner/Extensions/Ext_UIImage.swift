//
//  Ext_UIImage.swift
//  GriitChat
//
//  Created by leo on 24/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import Foundation

extension UIImage {
    func saveImage(savePath: String) -> Bool {
        let saveUrl = URL(fileURLWithPath: savePath);
        guard var data = UIImageJPEGRepresentation(self, 1) ?? UIImagePNGRepresentation(self) else {
            return false
        }
        do {
            try data.write(to: saveUrl);
            data.removeAll();
            return true
        } catch {
            print(error.localizedDescription)
            data.removeAll();
            return false
        }
    }
    
    static func load(filePath: String) -> UIImage? {
        let fileURL = URL(fileURLWithPath: filePath);
        do {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        } catch {
            print("Error loading image : \(error)")
        }
        return nil
    }
    
    static func base64_2Image(base64Str: String) -> UIImage {
        if (base64Str == "") { return UIImage(named: Assets.Default_User_Image)!}
        let dataDecoded: Data = Data(base64Encoded: base64Str, options: Data.Base64DecodingOptions(rawValue: 0))!
        
        return UIImage(data: dataDecoded)!
    }
    
    func resizeImage(newWidth: CGFloat) -> UIImage {
        let scale = newWidth / size.width
        let newHeight = size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    static func cropToBounds(image: UIImage, width: Double, height: Double) -> UIImage {
        let cgimage = image.cgImage!
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        let contextSize: CGSize = contextImage.size
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(width)
        var cgheight: CGFloat = CGFloat(height)
        
        // See what size is longer and create the center off of that
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }
        
        let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = cgimage.cropping(to: rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        
        return image
    }
    
    
    
    
    static func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
    static func downloadImageFromUrl(url: URL, completion: @escaping ((UIImage?) -> Void)) {
        print("Download Started")
        getDataFromUrl(url: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil);
                debugPrint(error?.localizedDescription);
                return
            }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")

            DispatchQueue.main.async() {
                let img: UIImage? = UIImage(data: data);
                if (data == nil ||
                    data.count == 0 ||
                    img == nil) { return }
                completion(img!);
            }
        }
    }
}

//
//  Photo+CoreDataProperties.swift
//  Diary
//
//  Created by Erik Carlson on 12/19/18.
//  Copyright © 2018 Round and Rhombus. All rights reserved.
//
//

import Foundation
import CoreData
import UIKit


extension Photo {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }
    
    @NSManaged public var imageData: NSData?
    @NSManaged public var post: Post?
}

// MARK: - Non-generated code.

extension Photo: CoreDataEntity {}

extension Photo {
    /// Get a UIImage from imageData or set imageData with a UIImage.
    /// Can be nil if there is something wrong with the data.
    var image: UIImage? {
        get {
            guard let nsData = imageData else {
                return nil
            }
            
            let data = nsData as Data
            
            return UIImage(data: data)
        }
        
        set {
            guard let newImage = newValue else {
                imageData = nil
                return
            }
            
            guard let pngData = newImage.pngData() else {
                imageData = nil
                return
            }
            
            imageData = pngData as NSData
        }
    }
}

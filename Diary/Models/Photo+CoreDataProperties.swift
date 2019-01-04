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
        let request = NSFetchRequest<Photo>(entityName: "Photo")
        let sortDescriptor = NSSortDescriptor(key: "createDate", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        return request
    }
    
    @NSManaged public var createDate: Date
    @NSManaged public var imageData: NSData
    @NSManaged public var thumbnailData: NSData
    @NSManaged public var post: Post?
}

// MARK: - Non-generated code.

extension Photo: CoreDataEntity {}

extension Photo: PhotoProtocol {}

extension Photo {
    /// Get a UIImage from imageData or set imageData with a UIImage.
    var image: UIImage {
        get {
            let data = imageData as Data
            
            guard let result = UIImage(data: data) else {
                print("Could not create UIImage from imageData.")
                return UIImage()
            }
            
            return result
        }
        
        set {
            guard let pngData = newValue.pngData() else {
                print("Could not create png data from UIImage.")
                return
            }
            
            imageData = pngData as NSData
        }
    }
    
    /// Get a UIImage from thumbnailData or set thumbnailData with a UIImage
    var thumbnailImage: UIImage {
        get {
            let data = thumbnailData as Data
            guard let result = UIImage(data: data) else {
                print("Could not create UIImage from thumbanilData.")
                return UIImage()
            }
            
            return result
        }
        
        set {
            guard let pngData = newValue.pngData() else {
                print("Could not create png data from thumbnailImage.")
                return
            }
            
            thumbnailData = pngData as NSData
        }
    }
    
    /**
     Copy attributes from a temp photo.
     
     - Parameter tempPhoto: The temp photo to copy from.
    */
    func copy(from tempPhoto: TempPhoto) {
        self.createDate = tempPhoto.createDate
        self.image = tempPhoto.image
        self.thumbnailImage = tempPhoto.thumbnailImage
    }
}

//
//  TempPhoto.swift
//  Diary
//
//  Created by Erik Carlson on 12/27/18.
//  Copyright © 2018 Round and Rhombus. All rights reserved.
//

import UIKit

class TempPhoto: PhotoProtocol {
    var photo: Photo?
    var createDate: Date
    var image: UIImage
    var thumbnailImage: UIImage
    
    init(photo: Photo) {
        self.photo = photo
        self.createDate = photo.createDate
        self.image = photo.image
        self.thumbnailImage = photo.thumbnailImage
    }
    
    /**
     Initialize by resizing the original image.
     
     - Parameter originalImage: The original image that will be resized.
    */
    init(originalImage: UIImage) {
        self.createDate = Date()
        self.image = UIImage()
        self.thumbnailImage = UIImage()
        setImages(originalImage)
    }
}


extension TempPhoto: Equatable {
    static func == (lhs: TempPhoto, rhs: TempPhoto) -> Bool {
        return lhs === rhs
    }
}

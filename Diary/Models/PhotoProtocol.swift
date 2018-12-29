//
//  PhotoProtocol.swift
//  Diary
//
//  Created by Erik Carlson on 12/27/18.
//  Copyright © 2018 Round and Rhombus. All rights reserved.
//

import UIKit

/// Used for Photo objects.
protocol PhotoProtocol: class {
    /// The creation date.
    var createDate: Date { get set }
    /// The full size image.
    var image: UIImage { get set }
    /// The thumbnail image.
    var thumbnailImage: UIImage { get set }
}

extension PhotoProtocol {
    /**
     Resize and set image and thumbnail image with original size image.
     
     - Parameter img: The original image to use to set image and thumbnailImage.
     - Returns: The resized images.
     */
    @discardableResult func setImages(_ img: UIImage) -> [String: UIImage] {
        var result = [String: UIImage]()
        let imageResult = img.resized(side: Photo.imageSize)
        image = imageResult
        result["image"] = imageResult
        let thumbnailResult = imageResult.resized(side: Photo.thumbnailSize)
        thumbnailImage = thumbnailResult
        result["thumbnailImage"] = thumbnailResult
        return result
    }
}

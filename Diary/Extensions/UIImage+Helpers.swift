//
//  UIImage+Helpers.swift
//  Diary
//
//  Created by Erik Carlson on 12/26/18.
//  Copyright © 2018 Round and Rhombus. All rights reserved.
//

import UIKit

extension UIImage {
    /**
     Get a resized copy of this image.
     
     - Parameter side: The length of the longest side. The width or height will be scaled to match.
    */
    func resized(side: CGFloat) -> UIImage {
        var newSize = CGSize.zero
        if size.width >= size.height {
            let ratio = side / size.width
            let newHeight = size.height * ratio
            newSize = CGSize(width: side, height: newHeight)
        } else {
            let ratio = side / size.height
            let newWidth = size.width * ratio
            newSize = CGSize(width: newWidth, height: side)
        }
        
        let newRect = CGRect(origin: CGPoint.zero, size: newSize)
        
        UIGraphicsBeginImageContext(newSize)
        draw(in: newRect)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else {
            print("UIImage.resized failed to get image from current image context.")
            return UIImage()
        }
        UIGraphicsEndImageContext()
        
        return result
    }
}

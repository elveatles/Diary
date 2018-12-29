//
//  Photo+CoreDataClass.swift
//  Diary
//
//  Created by Erik Carlson on 12/19/18.
//  Copyright © 2018 Round and Rhombus. All rights reserved.
//
//

import UIKit
import Foundation
import CoreData


public class Photo: NSManagedObject {
    /// The size in pixels to resize images.
    static let imageSize: CGFloat = 1080
    /// The size in pixels of a thumbnail.
    static let thumbnailSize: CGFloat = 128
}

//
//  Post+CoreDataClass.swift
//  Diary
//
//  Created by Erik Carlson on 12/19/18.
//  Copyright © 2018 Round and Rhombus. All rights reserved.
//
//

import Foundation
import CoreData


public class Post: NSManagedObject {
    /// A general mood for the Post.
    enum Mood: Int16 {
        case bad
        case average
        case good
    }
}

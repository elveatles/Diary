//
//  CoreDataEntity.swift
//  Diary
//
//  Created by Erik Carlson on 12/20/18.
//  Copyright © 2018 Round and Rhombus. All rights reserved.
//

import Foundation
import CoreData

/// Common things a CoreData class should have.
protocol CoreDataEntity {
    /// The name used to create and fetch the entity.
    static var entityName: String { get }
}

extension CoreDataEntity {
    static var entityName: String {
        return String(describing: Self.self)
    }
}

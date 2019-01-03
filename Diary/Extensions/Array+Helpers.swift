//
//  Array+Helpers.swift
//  Diary
//
//  Created by Erik Carlson on 12/28/18.
//  Copyright © 2018 Round and Rhombus. All rights reserved.
//

import Foundation

extension Array {
    /**
     Clamp an index to fit in the valid indices of the array.
     
     - Parameter index: The index to clamp.
     - Returns: The index clamped.
    */
    public func clampIndex(_ index: Int) -> Int {
        return Swift.min(Swift.max(0, index), count - 1)
    }
}

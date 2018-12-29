//
//  Style.swift
//  Diary
//
//  Created by Erik Carlson on 12/28/18.
//  Copyright © 2018 Round and Rhombus. All rights reserved.
//

import UIKit

/// Class for styling views.
class Style {
    /// Setup initial appearances on all views.
    static func setupAppearances() {
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = .gray
        appearance.currentPageIndicatorTintColor = .white
        appearance.backgroundColor = UIColor(white: 0.0, alpha: 0.2)
    }
}

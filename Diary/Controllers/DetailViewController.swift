//
//  DetailViewController.swift
//  Diary
//
//  Created by Erik Carlson on 12/19/18.
//  Copyright © 2018 Round and Rhombus. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    /// The post model with all the data needed to configure the UI.
    var post: Post?
    
//    func configureView() {
//        // Update the user interface for the detail item.
//        if let detail = detailItem {
//            if let label = detailDescriptionLabel {
//                label.text = detail.timestamp!.description
//            }
//        }
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        configureView()
    }

//    var detailItem: Event? {
//        didSet {
//            // Update the view.
//            configureView()
//        }
//    }


}


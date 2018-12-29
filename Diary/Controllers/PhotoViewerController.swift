//
//  PhotoViewerController.swift
//  Diary
//
//  Created by Erik Carlson on 12/27/18.
//  Copyright © 2018 Round and Rhombus. All rights reserved.
//

import UIKit

/// Displays a single photo.
class PhotoViewerController: UIViewController {
    static let storyboardIdentifier = String(describing: PhotoViewerController.self)
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    /// The photo to display.
    var photo: TempPhoto!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        photoImageView.image = photo.image
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

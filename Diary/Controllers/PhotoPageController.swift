//
//  PhotoPageController.swift
//  Diary
//
//  Created by Erik Carlson on 12/27/18.
//  Copyright © 2018 Round and Rhombus. All rights reserved.
//

import UIKit

/// Shows photos in a diary post.
class PhotoPageController: UIPageViewController {
    /// The photos to display.
    var photos = [TempPhoto]() {
        didSet {
            if oldValue.isEmpty && !photos.isEmpty {
                configure()
            }
        }
    }
    
    /// Get the current photo index.
    /// nil if photos is empty.
    var currentIndex: Int? {
        guard let controller = viewControllers?.first else { return nil }
        guard let photoVC = controller as? PhotoViewerController else { return nil }
        let result = photos.firstIndex(of: photoVC.photo)
        return result
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        configure()
    }
    
    /// Refresh the page view controller when new photos are added or deleted.
    func refresh() {
        // Sort of a hack since there seems to be no way to refresh a UIPageViewController.
        // Just reassign the viewControllers.
        setViewControllers(viewControllers, direction: .forward, animated: false, completion: nil)
    }
    
    /// Configure this view controller to display photos.
    func configure() {
        // Check if there are any photos to display and instantiate the initial PhotoViewController.
        guard let photo = photos.first,
            let photoVC = photoViewerController(with: photo) else {
            return
        }
        
        // Set the inital view controller.
        setViewControllers([photoVC], direction: .forward, animated: true, completion: nil)
    }
    
    /**
     Instantiate a PhotoViewerController with a Photo.
     
     - Parameter photo: The photo to assign to the view controller.
     - Returns: The instantiated view controller. nil if something goes wrong with instantiation.
     */
    func photoViewerController(with photo: TempPhoto) -> PhotoViewerController? {
        guard let photoVC = photoViewController() else { return nil }
        photoVC.photo = photo
        return photoVC
    }
    
    /**
     Instantiate a PhotoViewController from storyboard.
     
     - Returns: The instantiated view controller. nil if something went wrong.
    */
    func photoViewController() -> PhotoViewerController? {
        guard let storyboard = storyboard else { return nil }
        let photoVC = storyboard.instantiateViewController(withIdentifier: PhotoViewerController.storyboardIdentifier) as? PhotoViewerController
        return photoVC
    }
    
    /**
     Add a photo.
     
     - Parameter photo: The photo to add.
    */
    func addPhoto(_ photo: TempPhoto) {
        photos.append(photo)
    }
    
    /// Delete the current photo and change the current view controller to the next available one.
    /// Nothing happens if there are no photos.
    func deleteCurrentPhoto() {
        // Get the current photo index. Do nothing if there are no photos.
        guard let index = currentIndex else { return }
        // Remove the photo.
        photos.remove(at: index)
        // If there are no photos after removing, set the current view controller to a default view controller.
        if photos.isEmpty {
            setViewControllers([UIViewController()], direction: .forward, animated: true, completion: nil)
            return
        }
        // Get the index of the photo that will become the new current photo.
        let newIndex = photos.clampIndex(index)
        // Create the view controller with the photo.
        guard let photoVC = photoViewerController(with: photos[newIndex]) else {
            print("PhotoPageController.deleteCurrentPhoto: failed to create PhotoViewerController.")
            return
        }
        // Animation direction.
        let direction: UIPageViewController.NavigationDirection = newIndex < index ? .reverse : .forward
        // Set the new view controller.
        setViewControllers([photoVC], direction: direction, animated: true, completion: nil)
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


extension PhotoPageController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        // Get the current PhotoViewerController.
        guard let photoVC = viewController as? PhotoViewerController else { return nil }
        
        // Get the index of the current photo.
        guard let index = photos.firstIndex(of: photoVC.photo) else { return nil }
        
        // Check if the index is the start index.
        if index == photos.startIndex { return nil }
        
        // Create the view controller before the current view controller.
        let indexBefore = photos.index(before: index)
        let photo = photos[indexBefore]
        return photoViewerController(with: photo)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        // Get the current PhotoViewerController.
        guard let photoVC = viewController as? PhotoViewerController else { return nil }
        
        // Get the index of the current photo.
        guard let index = photos.firstIndex(of: photoVC.photo) else { return nil }
        
        // Check if the index is the end index.
        if index == photos.index(before: photos.endIndex) { return nil }
        
        // Create the view controller after the current view controller.
        let indexAfter = photos.index(after: index)
        let photo = photos[indexAfter]
        return photoViewerController(with: photo)
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return photos.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return currentIndex ?? 0
    }
}

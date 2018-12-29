//
//  DetailViewController.swift
//  Diary
//
//  Created by Erik Carlson on 12/19/18.
//  Copyright © 2018 Round and Rhombus. All rights reserved.
//

import UIKit
import CoreLocation
import MobileCoreServices
import Photos

/// Shows a diary entry that can be edited or allows a user to create a new one.
class DetailViewController: UIViewController {
    /// The mode of the DetailViewController.
    enum Mode {
        /// Editing an existing post.
        case editPost
        /// Creating a new post.
        case newPost
    }
    
    @IBOutlet weak var pictureButton: UIButton!
    @IBOutlet weak var moodImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageLabel: UITextView!
    @IBOutlet weak var addLocationButton: UIButton!
    @IBOutlet weak var charLimitLabel: UILabel!
    
    /// Reference to the photo page controller inside the container view.
    var photoPageController: PhotoPageController!
    /// The mode to work in. Whether this is a new post or not.
    var mode = Mode.editPost
    /// The post model with all the data needed to configure the UI.
    var post: Post?
    /// The current mood chosen for the post.
    var mood: Post.Mood? {
        didSet {
            guard let mood = mood else {
                moodImageView.image = nil
                return
            }
            
            switch mood {
            case .bad: moodImageView.image = #imageLiteral(resourceName: "icn_bad")
            case .average: moodImageView.image = #imageLiteral(resourceName: "icn_average")
            case .good: moodImageView.image = #imageLiteral(resourceName: "icn_happy")
            }
        }
    }
    /// The current location name.
    /// Sets addLocationButton title as well.
    var locationName: String? {
        didSet {
            if let name = locationName {
                addLocationButton.setTitle(name, for: .normal)
            } else {
                addLocationButton.setTitle("Add location", for: .normal)
            }
        }
    }
    /// Let's the user choose photos for their diary entry.
    private lazy var imagePickerController: UIImagePickerController = {
        let result = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            result.sourceType = .camera
        } else {
            result.sourceType = .photoLibrary
        }
        result.mediaTypes = [kUTTypeImage as String]
        return result
    }()
    /// Delegate for the message text view
    private lazy var messageDelegate: PostMessageDelegate = {
        let result = PostMessageDelegate(messageTextView: messageLabel, textCountLabel: charLimitLabel)
        result.placeholderText = "What happened today?"
        return result
    }()
    /// This flag is needed because CLLocationManagerDelegate will call
    /// locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    /// even though CLLocationManager.requestWhenInUseAuthorization() was not called.
    private var locationAuthRequested = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageLabel.delegate = messageDelegate
        imagePickerController.delegate = self
        AppDelegate.locationManager.delegate = self
        
        // Make picture button a circle.
        pictureButton.layer.cornerRadius = 0.5 * pictureButton.bounds.size.width
        pictureButton.clipsToBounds = true
        
        configureView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedPhotos" {
            photoPageController = segue.destination as? PhotoPageController
        }
    }
    
    /// Save the post.
    @IBAction func savePost(_ sender: UIBarButtonItem) {
        // Check for required fields.
        // Post must at least contain a message.
        guard messageDelegate.textCountStripped > 0 else {
            showAlert(title: "No Text", message: "Cannot save a diary entry without any text.")
            return
        }
        
        // New post creation
        if mode == .newPost {
            post = CoreDataStack.main.newObject()
            post?.createDate = Date()
            post?.updateSection()
        }
        
        guard let post = post else { return }
        
        // Take all the data from the UI and put it in the Post CoreData object.
        post.message = messageLabel.text
        if let mood = mood {
            post.mood = mood.rawValue as NSNumber
        } else {
            post.mood = nil
        }
        post.location = locationName
        applyPhotoDeletions()
        post.photos = tempPhotosToPhotos()
        
        CoreDataStack.main.saveContext()
        
        goBackToMaster()
    }
    
    /// Check photo library authorization and present imagePicker controller
    /// if the user allows it.
    @IBAction func pickPhotosToAdd() {
        // Check photo library authorization status.
        switch PHPhotoLibrary.authorizationStatus() {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { (newStatus) in
                switch newStatus {
                case .notDetermined:
                    print("Photo auth not determined.")
                case .authorized:
                    print("Authorized")
                    self.present(self.imagePickerController, animated: true, completion: nil)
                case .denied, .restricted:
                    self.showPhotoAuthDeniedAlert()
                }
            }
        case .authorized:
            present(imagePickerController, animated: true, completion: nil)
        case .denied, .restricted:
            showPhotoAuthDeniedAlert()
        }
    }
    
    @IBAction func pickPhotosToAdd(_ sender: UIBarButtonItem) {
        pickPhotosToAdd()
    }
    
    
    /// Delete the current photo being shown in photoPageController.
    @IBAction func deleteCurrentPhoto(_ sender: UIBarButtonItem) {
        photoPageController.deleteCurrentPhoto()
        updateThumbnailPhoto()
    }
    
    /// Authorize location services if needed then request the location to add.
    @IBAction func addLocation() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationAuthRequested = true
            AppDelegate.locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            AppDelegate.locationManager.requestLocation()
        case .denied, .restricted:
            showLocationAuthDeniedAlert()
        case .authorizedAlways:
            print("Location .authorizedAlways not implemented.")
        }
    }
    
    @IBAction func badChosen() {
        mood = .bad
    }
    
    @IBAction func averageChosen() {
        mood = .average
    }
    
    @IBAction func goodChosen() {
        mood = .good
    }
    
    /// Configure the view depending on the mode and post.
    func configureView() {
        switch mode {
        case .newPost: configureViewNew()
        case .editPost: configureViewEdit()
        }
    }
    
    /// Update the thumbnail photo.
    /// Useful if the photo used for the thumbnail is deleted or a new photo was added.
    func updateThumbnailPhoto() {
        var image = #imageLiteral(resourceName: "post_image_default")
        if let photo = photoPageController.photos.first {
            image = photo.thumbnailImage
        }
        pictureButton.setImage(image, for: .normal)
    }
    
    /**
     Add an image to photos.
     
     - Parameter image: The image to add.
    */
    func addImage(_ image: UIImage) {
        let photo = TempPhoto(originalImage: image)
        photoPageController.addPhoto(photo)
        photoPageController.refresh()
        updateThumbnailPhoto()
    }
    
    /// Because this is a detail view controller presented in a split view controller,
    /// using navigationController?.popViewController(animated: true) is not going to work.
    /// Instead, we have to get the master navigation controller and pop to root.
    func goBackToMaster() {
        navigationController?.navigationController?.popToRootViewController(animated: true)
    }
    
    /// Configure the view for a new post.
    private func configureViewNew() {
        let image = #imageLiteral(resourceName: "post_image_default")
        pictureButton.setImage(image, for: .normal)
        mood = nil
        dateLabel.text = PostCell.dateFormatter.string(from: Date())
        setMessageText("")
        locationName = nil
    }
    
    
    private func configureViewEdit() {
        guard let post = post else {
            print("DetailViewController.configureViewEdit: no post available.")
            return
        }
        
        mood = post.moodEnum
        dateLabel.text = PostCell.dateFormatter.string(from: post.createDate)
        setMessageText(post.message)
        locationName = post.location
        photoPageController.photos = photosToTempPhotos()
        updateThumbnailPhoto()
    }
    
    /**
     Set the message text, and update its delegate.
     
     Use this instead of setting text on messageLabel directly since
     placeholder text will not work otherwise.
     
     - Parameter text: The text to set for message.
    */
    private func setMessageText(_ text: String?) {
        messageLabel.text = text
        messageDelegate.textViewDidEndEditing(messageLabel)
        messageDelegate.updateTextCount()
    }
    
    /**
     Convert an array of Photo object to an array of TempPhoto object.
     
     - Returns: The converted photo objects.
    */
    private func photosToTempPhotos() -> [TempPhoto] {
        guard let photos = post?.photos else { return [] }
        let converted = photos.map { TempPhoto(photo: $0) }
        return converted.sorted { $0.createDate < $1.createDate }
    }
    
    /// Take any temp photos that were deleted and apply the deletion to their associated CoreData photos.
    /// When a user deletes a photo while they are editing a post, it only deletes the TempPhoto without
    /// making any changes to CoreData. CoreData photos are then deleted afterwards if the user decides to
    /// save the post edits.
    /// This must be called before reassigning post.photos.
    private func applyPhotoDeletions() {
        guard let post = post else { return }
        // Get photos from temp photos that have an associated CoreData object.
        let photosFromTemp = photoPageController.photos.compactMap { $0.photo }
        // Find which photos to delete by comparing the photos we started with, with the photos we have now.
        let toDelete = post.photos.subtracting(photosFromTemp)
        // Delete the photos (Not saved yet).
        for photo in toDelete {
            CoreDataStack.main.deleteObject(photo)
        }
    }
    
    /**
     Convert temp photos to CoreData Photos.
     
     - Returns: The converted photos.
    */
    private func tempPhotosToPhotos() -> Set<Photo> {
        var converted = Set<Photo>()
        for tempPhoto in photoPageController.photos {
            if let photo = tempPhoto.photo {
                converted.insert(photo)
            } else {
                let photo: Photo = CoreDataStack.main.newObject()
                photo.copy(from: tempPhoto)
                converted.insert(photo)
            }
        }
        
        return converted
    }
}


extension DetailViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        // Check the location status.
        if locationAuthRequested {
            switch status {
            case .denied, .restricted:
                showLocationAuthDeniedAlert()
            case .authorizedWhenInUse:
                // This is the authorization we want.
                AppDelegate.locationManager.requestLocation()
                break
            default:
                print("Unexpected location auth status: \(status)")
            }
        }
        
        locationAuthRequested = false
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        showAlert(title: "Location Error", message: error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // There should always be at least 1 location.
        guard let location = locations.first else { return }
        
        getLocationName(location: location)
    }
    
    /**
     Get a location name from coordinates.
     
     Sets the addLocationButton title.
     
     - Parameter location: The location coordinates to get the location from.
     */
    private func getLocationName(location: CLLocation) {
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            guard let s = self else { return }
            
            // Check for error
            if let error = error {
                s.showAlert(title: "Location Name Error", message: "Could not get the name of your location: \(error.localizedDescription)")
                return
            }
            
            guard let placemark = placemarks?.first else { return }
            
            // Create the location name and assign it to the location button.
            if let thoroughfare = placemark.thoroughfare,
                let locality = placemark.locality,
                let administrativeArea = placemark.administrativeArea {
                s.locationName = "\(thoroughfare) - \(locality), \(administrativeArea)"
            } else {
                s.locationName = "Unknown"
            }
            
        }
    }
    
    /// Show an alert informing the user that locations cannot be fetched because
    /// the app is not authorized to do so.
    private func showLocationAuthDeniedAlert() {
        showAlert(
            title: "Location Authorization",
            message: "Cannot get location because authorization was denied or restricted.")
    }
}


extension DetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Get the selected image from the image picker.
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        // Add the image.
        addImage(image)
        // Dismiss the image picker.
        imagePickerController.dismiss(animated: true, completion: nil)
    }
    
    /// Show an alert informing the user that photos cannot be used because
    /// the app is not authorized to do so.
    private func showPhotoAuthDeniedAlert() {
        showAlert(
            title: "Photos Authorization",
            message: "Cannot access photos because authorization was denied or restricted.")
    }
}

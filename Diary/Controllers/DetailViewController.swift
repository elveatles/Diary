//
//  DetailViewController.swift
//  Diary
//
//  Created by Erik Carlson on 12/19/18.
//  Copyright © 2018 Round and Rhombus. All rights reserved.
//

import UIKit

/// Shows a diary entry that can be edited or allows a user to create a new one.
class DetailViewController: UIViewController {
    /// The mode of the DetailViewController.
    enum Mode {
        /// Editing an existing post.
        case editPost
        /// Creating a new post.
        case newPost
    }
    
    @IBOutlet weak var pictureLabel: UIImageView!
    @IBOutlet weak var moodImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageLabel: UITextView!
    @IBOutlet weak var addLocationButton: UIButton!
    @IBOutlet weak var charLimitLabel: UILabel!
    
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
    /// Delegate for the message text view
    private lazy var messageDelegate: PostMessageDelegate = {
        let result = PostMessageDelegate(messageTextView: messageLabel, textCountLabel: charLimitLabel)
        result.placeholderText = "What happened today?"
        return result
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageLabel.delegate = messageDelegate
        
        configureView()
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
        
        guard let post = post else {
            return
        }
        
        // Take all the data from the UI and put it in the Post CoreData object.
        post.message = messageLabel.text
        if let mood = mood {
            post.mood = mood.rawValue as NSNumber
        } else {
            post.mood = nil
        }
        
        CoreDataStack.main.saveContext()
        
        goBackToMaster()
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
        case .newPost: configureViewForNewPost()
        case .editPost: configureViewForEditPost()
        }
    }
    
    /// Because this is a detail view controller presented in a split view controller,
    /// using navigationController?.popViewController(animated: true) is not going to work.
    /// Instead, we have to get the master navigation controller and pop to root.
    func goBackToMaster() {
        navigationController?.navigationController?.popToRootViewController(animated: true)
    }
    
    /// Configure the view for a new post
    private func configureViewForNewPost() {
        pictureLabel.image = #imageLiteral(resourceName: "post_image_default")
        mood = nil
        dateLabel.text = PostCell.dateFormatter.string(from: Date())
        setMessageText("")
        addLocationButton.setTitle("Add location", for: .normal)
    }
    
    /// Configure the view to edit an existing post.
    private func configureViewForEditPost() {
        guard let post = post else {
            print("DetailViewController.configureView: mode is editPost, but a Post object was not injected.")
            return
        }
        
        // Main photo
        if let photo = post.photos.first {
            pictureLabel.image = photo.image
        } else {
            pictureLabel.image = #imageLiteral(resourceName: "post_image_default")
        }
        
        mood = post.moodEnum
        dateLabel.text = PostCell.dateFormatter.string(from: post.createDate)
        setMessageText(post.message)
        
        // Location
        if let location = post.location, !location.isEmpty {
            addLocationButton.setTitle(location, for: .normal)
        } else {
            addLocationButton.setTitle("Add location", for: .normal)
        }
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
}


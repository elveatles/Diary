//
//  PostCell.swift
//  Diary
//
//  Created by Erik Carlson on 12/19/18.
//  Copyright © 2018 Round and Rhombus. All rights reserved.
//

import UIKit

/// A cell that shows the contents of a diary post.
class PostCell: UITableViewCell {
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var moodImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var locationStackView: UIStackView!
    @IBOutlet weak var locationLabel: UILabel!
    
    static let cellIdentifier = String(describing: PostCell.self)
    /// The date format for titleLable. Example: "Monday 25 November".
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE d MMMM"
        return formatter
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    /// Configure the view with a post.
    /// - Parameter post: The post to show.
    func configure(_ post: Post) {
        // Photo
        if let photo = post.photosSorted.first {
            photoImageView.image = photo.image
        } else {
            photoImageView.image = #imageLiteral(resourceName: "post_image_default")
        }
        
        // Mood
        if let mood = post.moodEnum {
            switch mood {
            case .bad:
                moodImageView.image = #imageLiteral(resourceName: "icn_bad")
            case .average:
                moodImageView.image = #imageLiteral(resourceName: "icn_average")
            case .good:
                moodImageView.image = #imageLiteral(resourceName: "icn_happy")
            }
        } else {
            moodImageView.image = nil
        }
        
        // Create Date
        titleLabel.text = PostCell.dateFormatter.string(from: post.createDate)
        // Message
        messageLabel.text = post.message
        
        // Location
        if let location = post.location {
            locationStackView.isHidden = false
            locationLabel.text = location
        } else {
            locationStackView.isHidden = true
        }
    }
}

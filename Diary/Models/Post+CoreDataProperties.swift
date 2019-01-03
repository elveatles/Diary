//
//  Post+CoreDataProperties.swift
//  Diary
//
//  Created by Erik Carlson on 12/19/18.
//  Copyright © 2018 Round and Rhombus. All rights reserved.
//
//

import Foundation
import CoreData


extension Post {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Post> {
        let request = NSFetchRequest<Post>(entityName: "Post")
        let sortDescriptor = NSSortDescriptor(key: "createDate", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        return request
    }

    @NSManaged public var createDate: Date
    @NSManaged public var message: String
    @NSManaged public var location: String?
    @NSManaged public var mood: NSNumber?
    @NSManaged public var photos: Set<Photo>
    @NSManaged public var section: String
}

// MARK: Generated accessors for photos
extension Post {

    @objc(addPhotosObject:)
    @NSManaged public func addToPhotos(_ value: Photo)

    @objc(removePhotosObject:)
    @NSManaged public func removeFromPhotos(_ value: Photo)

    @objc(addPhotos:)
    @NSManaged public func addToPhotos(_ values: NSSet)

    @objc(removePhotos:)
    @NSManaged public func removeFromPhotos(_ values: NSSet)

}

// MARK: - Non-generated code

extension Post: CoreDataEntity {}

extension Post {
    /// Get the Date formatter for a section.
    static var sectionFormatter: DateFormatter {
        let result = DateFormatter()
        result.dateFormat = "yyyy-MM"
        return result
    }
    
    /// Get or set the mood as an enum value.
    var moodEnum: Mood? {
        get {
            guard let mood = mood else { return nil }
            return Mood(rawValue: mood.int16Value)
        }
        
        set {
            guard let newMood = newValue else {
                mood = nil
                return
            }
            
            mood = newMood.rawValue as NSNumber
        }
    }
    
    /// Get the photos sorted by createDate.
    var photosSorted: [Photo] {
        return photos.sorted { $0.createDate < $1.createDate }
    }
    
    /// Updates section with the value of createDate
    func updateSection() {
        section = Post.sectionFormatter.string(from: createDate)
    }
}

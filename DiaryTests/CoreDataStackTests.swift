//
//  CoreDataStackTests.swift
//  DiaryTests
//
//  Created by Erik Carlson on 1/3/19.
//  Copyright © 2019 Round and Rhombus. All rights reserved.
//

import XCTest
import CoreData
import UIKit
@testable import Diary

class CoreDataStackTests: XCTestCase {
    /// The CoreData stack to test with.
    var coreDataStack: CoreDataStack!
    /// The message for the test post. Used in NSPredicate to find the post again.
    let postMessage = "TestPost"
    
    /// Setup the CoreData stack to use in-memory persistent storage (Fake).
    func setupCoreDataStack() {
        // Is this commented code needed?
        // let bundle = Bundle(for: type(of: self))
        // let mockModel = NSManagedObjectModel.mergedModel(from: [bundle])!
        // let mockPContainer = NSPersistentContainer(name: "Diary", managedObjectModel: mockModel)
        
        let mockContainer = NSPersistentContainer(name: "Diary")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false // Make it simpler in test env
        mockContainer.persistentStoreDescriptions = [description]
        mockContainer.loadPersistentStores { (description, error) in
            // Check if the data store is in memory
            precondition(description.type == NSInMemoryStoreType)
            
            if let error = error {
                fatalError("Create in-memory coordinator failed: \(error)")
            }
        }
        
        coreDataStack = CoreDataStack(container: mockContainer)
    }
    
    /// Delete all objects from the in-memory CoreData stack.
    func flushData() {
        let request: NSFetchRequest<Post> = Post.fetchRequest()
        let posts = try! coreDataStack.context.fetch(request)
        for post in posts {
            coreDataStack.deleteObject(post)
        }
        coreDataStack.saveContext()
    }
    
    /// Create a test Post entity with a single Photo entity for its photos property.
    /// Does not save the context.
    /// - Returns: The test post created.
    @discardableResult func createTestPost() -> Post {
        let post: Post = coreDataStack.newObject()
        post.createDate = Date()
        post.updateSection()
        post.message = postMessage
        post.location = "Stockton St - San Francisco"
        post.moodEnum = Post.Mood.good
        
        let photo: Photo = coreDataStack.newObject()
        photo.createDate = Date()
        let testImage = #imageLiteral(resourceName: "test")
        photo.setImages(testImage)
        post.photos = [photo]
        
        return post
    }
    
    /// Fetch the test post that was created with `createTestPost`.
    /// - Returns: The test post created. nil if the post was not created.
    func fetchTestPost() -> Post? {
        let request: NSFetchRequest<Post> = Post.fetchRequest()
        request.predicate = NSPredicate(format: "message = '\(postMessage)'")
        do {
            let result = try coreDataStack.context.fetch(request)
            return result.first
        } catch {
            print("fetchTestPost error:")
            print(error)
            return nil
        }
    }
    
    override func setUp() {
        setupCoreDataStack()
    }

    override func tearDown() {
        flushData()
    }
    
    /// Test saving a post.
    func testSavePost() {
        createTestPost()
        coreDataStack.saveContext()
        let fetchedPost = fetchTestPost()
        XCTAssertNotNil(fetchedPost)
    }
    
    /// Test editing a post and saving it.
    func testEditPost() {
        createTestPost()
        coreDataStack.saveContext()
        
        guard let fetchedPost = fetchTestPost() else {
            XCTFail("Could not fetch post to edit.")
            return
        }
        
        fetchedPost.mood = nil
        fetchedPost.location = nil
        
        coreDataStack.saveContext()
        
        guard let editedPost = fetchTestPost() else {
            XCTFail("Could not fetch edited post.")
            return
        }
        
        XCTAssertNil(editedPost.mood)
        XCTAssertNil(editedPost.location)
    }
    
    /// Test deleting a post.
    func testDeletePost() {
        createTestPost()
        coreDataStack.saveContext()
        
        guard let fetchedPost = fetchTestPost() else {
            XCTFail("Could not fetch post to delete.")
            return
        }
        
        coreDataStack.deleteObject(fetchedPost)
        coreDataStack.saveContext()
        
        let deletedPost = fetchTestPost()
        XCTAssertNil(deletedPost)
    }
}

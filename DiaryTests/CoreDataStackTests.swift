//
//  CoreDataStackTests.swift
//  DiaryTests
//
//  Created by Erik Carlson on 1/3/19.
//  Copyright © 2019 Round and Rhombus. All rights reserved.
//

import XCTest
import CoreData
@testable import Diary

class CoreDataStackTests: XCTestCase {
    var coreDataStack: CoreDataStack!
    
    /// Setup the CoreData stack to use in-memory persistent storage (Fake).
    func setupCoreDataStack() {
        //let bundle = Bundle(for: type(of: self))
        // let mockModel = NSManagedObjectModel.mergedModel(from: [bundle])!
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
    
    override func setUp() {
        setupCoreDataStack()
    }

    override func tearDown() {
        flushData()
    }
    
    func testSavePost() {
        let post: Post = coreDataStack.newObject()
        let now = Date()
        post.createDate = now
        post.updateSection()
        post.message = "message"
        post.location = "Stockton St - San Francisco"
        post.moodEnum = Post.Mood.good
        
        let photo: Photo = coreDataStack.newObject()
        photo.image = UIImage()
        photo.thumbnailImage = UIImage()
        
        post.photos = [photo]
        
        coreDataStack.saveContext()
        
        let request: NSFetchRequest<Post> = Post.fetchRequest()
        let result = try! coreDataStack.context.fetch(request)
        let loadedPost = result.firstIndex(of: post)
        XCTAssertNotNil(loadedPost)
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

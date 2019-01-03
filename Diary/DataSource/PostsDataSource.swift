//
//  PostListDataSource.swift
//  Diary
//
//  Created by Erik Carlson on 12/20/18.
//  Copyright © 2018 Round and Rhombus. All rights reserved.
//

import UIKit
import CoreData

/// Data source for Posts.
class PostsDataSource: NSObject, UITableViewDataSource {
    /// Date formatter for section header titles.
    static let sectionDateFormatter: DateFormatter = {
        let result = DateFormatter()
        result.dateFormat = "MMMM yyyy"
        return result
    }()
    /// The table view the data source is for.
    let tableView: UITableView
    
    lazy var fetchDelegate: PostsFetchDelegate = PostsFetchDelegate(tableView: tableView)
    /// Callback that is called right before a post is deleted.
    var postWillDelete: ((IndexPath) -> Void)?
    
    /// Fetched results controller used for managing core data fetches for the data source.
    lazy var fetchedResultsController: NSFetchedResultsController<Post> = {
        let fetchRequest: NSFetchRequest<Post> = Post.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "createDate", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let context = CoreDataStack.main.context
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: "section", cacheName: "Master")
        aFetchedResultsController.delegate = fetchDelegate
        
        do {
            try aFetchedResultsController.performFetch()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return aFetchedResultsController
    }()
    
    init(tableView: UITableView) {
        self.tableView = tableView
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionInfo = fetchedResultsController.sections?[section] else { return nil }
        
        // Convert the date format stored in CoreData to the format used for section header titles.
        guard let date = Post.sectionFormatter.date(from: sectionInfo.name) else { return nil }
        let title = PostsDataSource.sectionDateFormatter.string(from: date)
        return title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PostCell.cellIdentifier, for: indexPath) as! PostCell
        let post = fetchedResultsController.object(at: indexPath)
        cell.configure(post)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            postWillDelete?(indexPath)
            
            let post = object(at: indexPath)
            CoreDataStack.main.deleteObject(post)
            CoreDataStack.main.saveContext()
        }
    }
    
    /**
     Get the Post object at a certain index path.
     
     - Parameter indexPath: The index path to get the post from.
     - Returns: The Post at the index path.
    */
    func object(at indexPath: IndexPath) -> Post {
        return fetchedResultsController.object(at: indexPath)
    }
    
    /**
     Change the search text being used.
     
     Need to reload the tableView after calling this.
     
     - Parameter text: The text to search for.
     - Throws: Any error that NSFetchedResultsController throws.
    */
    func search(for text: String) throws {
        // Must delete cache before changing the predicate.
        NSFetchedResultsController<Post>.deleteCache(withName: "Master")
        
        var predicate: NSPredicate?
        if !text.isEmpty {
            predicate = NSPredicate(format: "message CONTAINS[cd] %@", text)
        }
        fetchedResultsController.fetchRequest.predicate = predicate
        
        try fetchedResultsController.performFetch()
    }
}

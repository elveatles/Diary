//
//  CoreDataStack.swift
//  Diary
//
//  Created by Erik Carlson on 12/19/18.
//  Copyright © 2018 Round and Rhombus. All rights reserved.
//

import Foundation
import CoreData

/// Convenient interface to the CoreData stack.
class CoreDataStack {
    /// The persistent container that this class wraps.
    let persistentContainer: NSPersistentContainer
    
    /**
     Initialize with a given persistent container.
     
     - Parameter container: The persistent container to use. This will be different depending on whether this class will be used in production or testing.
    */
    init(container: NSPersistentContainer) {
        self.persistentContainer = container
    }
    
    /// Convenience function for persistentContainer.viewContext.
    lazy var context: NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()
    
    /// Create a new entity object with this CoreData stack.
    func newObject<T: CoreDataEntity>() -> T {
        return NSEntityDescription.insertNewObject(forEntityName: T.entityName, into: context) as! T
    }
    
    /// Convenience function for deleting a CoreData object with the stored context.
    /// - Parameter object: The object to delete.
    func deleteObject(_ object: NSManagedObject) {
        context.delete(object)
    }
    
    // MARK: - Core Data Saving support
    
    /// Auto-created with project when "Core Data" checkbox is checked.
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

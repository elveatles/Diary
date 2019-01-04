//
//  MasterViewController.swift
//  Diary
//
//  Created by Erik Carlson on 12/19/18.
//  Copyright © 2018 Round and Rhombus. All rights reserved.
//

import UIKit
import CoreData

/// Master that shows a list of diary posts.
class MasterViewController: UITableViewController {
    /// The date formatter for the navigation item title date.
    static var navigationDateFormatter: DateFormatter = {
        let result = DateFormatter()
        result.dateStyle = .long
        result.timeStyle = .none
        return result
    }()
    
    /// Posts data source for the table view.
    lazy var postsDataSource: PostsDataSource = {
        let result = PostsDataSource(tableView: tableView)
        result.postWillDelete = postWillDelete
        return result
    }()
    /// Delegate for the table view
    lazy var postsTableDelegate: PostsTableDelegate = {
        return PostsTableDelegate()
    }()
    let searchController = UISearchController(searchResultsController: nil)
    private var detailViewController: DetailViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get the detail controller and assign it to the property.
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        navigationController?.navigationBar.tintColor = .white
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.dataSource = postsDataSource
        tableView.delegate = postsTableDelegate
        tableView.tableHeaderView = searchController.searchBar
        
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        navigationItem.title = MasterViewController.navigationDateFormatter.string(from: Date())
        super.viewWillAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            // Get DetailViewController
            let destination = segue.destination as! UINavigationController
            let controller = destination.topViewController as! DetailViewController
            detailViewController = controller
            // Write a New post
            if let obj = sender, let newPost = obj as? Bool, newPost == true {
                controller.post = nil
            }
            // If a table view cell was selected, get the Post for that cell,
            // and assign it to DetailViewController.post.
            else if let indexPath = tableView.indexPathForSelectedRow {
                controller.post = postsDataSource.object(at: indexPath)
            }
            
            // Split view controller fiddling with the nav bar back button
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
            controller.updateNavigationTitle()
        }
    }
    
    /// Segue to the detail controller in "new post" mode.
    @IBAction func writeNewPost(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "showDetail", sender: true)
    }
    
    /// If the post that will be deleted is being shown in the detail controller,
    /// the detail controller will need to be updated so that it does not use
    /// the deleted Post data anymore.
    private func postWillDelete(indexPath: IndexPath) {
        guard let controller = detailViewController else { return }
        let post = postsDataSource.object(at: indexPath)
        if post == controller.post {
            controller.post = nil
        }
    }
}


extension MasterViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // Update the search text for the data source's fetched results controller.
        let text = searchController.searchBar.text ?? ""
        do {
            try postsDataSource.search(for: text)
            tableView.reloadData()
        } catch {
            print(error)
        }
    }
}

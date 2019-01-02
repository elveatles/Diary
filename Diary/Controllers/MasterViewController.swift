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
    /// Posts data source for the table view.
    lazy var postsDataSource: PostsDataSource = {
        return PostsDataSource(tableView: tableView)
    }()
    /// Delegate for the table view
    lazy var postsTableDelegate: PostsTableDelegate = {
        return PostsTableDelegate()
    }()
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.dataSource = postsDataSource
        tableView.delegate = postsTableDelegate
        tableView.tableHeaderView = searchController.searchBar
        
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            // Get DetailViewController
            let destination = segue.destination as! UINavigationController
            let controller = destination.topViewController as! DetailViewController
            // Set the mode (New Post or Edit Post)
            if let mode = sender as? DetailViewController.Mode {
                controller.mode = mode
            } else {
                controller.mode = .editPost
            }
            // If a table view cell was selected, get the Post for that cell,
            // and assign it to DetailViewController.post.
            if let indexPath = tableView.indexPathForSelectedRow {
                controller.post = postsDataSource.object(at: indexPath)
                // Split view controller fiddling with the nav bar back button
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    @IBAction func writeNewPost(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "showDetail", sender: DetailViewController.Mode.newPost)
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

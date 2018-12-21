//
//  PostsTableDelegate.swift
//  Diary
//
//  Created by Erik Carlson on 12/20/18.
//  Copyright © 2018 Round and Rhombus. All rights reserved.
//

import UIKit

/// Delegate for the master table view posts.
class PostsTableDelegate: NSObject, UITableViewDelegate {
    let headerTextColor = #colorLiteral(red: 0.2352941176, green: 0.3058823529, blue: 0.4274509804, alpha: 1)
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        
        header.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
        header.textLabel?.text = header.textLabel?.text?.capitalized
        header.textLabel?.textColor = headerTextColor
    }
}

//
//  GroceryListViewController.swift
//  Grocery SOS
//
//  Created by Prithvi Rajesh Lalla on 2/24/16.
//  Copyright © 2016 Grocery SOS. All rights reserved.
//

import UIKit

class GroceryListViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchTable: UITableView!
    
    var items = [GroceryItem]()
    var searchResults = [GroceryItem]()
    var checkedItems = [GroceryItem]()
    var hasSearched = false
    let emptySearchMessage = "(Nothing found)"

    override func viewDidLoad() {
        super.viewDidLoad()
        items.append(GroceryItem(name: "Milk"))
        items.append(GroceryItem(name: "Meat"))
        items.append(GroceryItem(name: "Cheese"))
        items.append(GroceryItem(name: "Bread"))
        items.append(GroceryItem(name: "Vegetables"))
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func toggleCheckmark(name: String) {
        for item in items {
            if item.name == name {
                if item.checkmark {
                    item.checkmark = false
                    removeCheckedItem(item)
                } else {
                    item.checkmark = true
                    checkedItems.append(item)
                }
            }
        }
    }
    
    func removeCheckedItem(target: GroceryItem) {
        for i in 0...(checkedItems.count - 1) {
            if checkedItems[i].equalTo(target) {
                checkedItems.removeAtIndex(i)
                break
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension GroceryListViewController: UISearchBarDelegate {
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText != "" {
            hasSearched = true
        } else {
            hasSearched = false
        }
        searchResults.removeAll(keepCapacity: false)
        for item in items {
            if item.name.contains(searchBar.text!) {
                searchResults.append(item)
            }
        }
        searchTable.reloadData()
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.text = ""
        hasSearched = false
        searchTable.reloadData()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
}

extension GroceryListViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "TableViewCell"
        var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellIdentifier)
        }
        if hasSearched {
            if searchResults.count == 0 {
                cell.textLabel!.text = emptySearchMessage
            } else {
                cell.textLabel!.text = searchResults[indexPath.row].name
                if searchResults[indexPath.row].checkmark {
                    cell.accessoryType = .Checkmark
                } else {
                    cell.accessoryType = .None
                }
            }
        } else {
            cell.textLabel!.text = checkedItems[indexPath.row].name
            cell.accessoryType = .Checkmark
        }
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if hasSearched {
            if searchResults.count == 0 && hasSearched {
                return 1
            }
            return searchResults.count
        } else {
            return checkedItems.count
        }
    }
    
}

extension GroceryListViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        if cell.textLabel!.text != emptySearchMessage {
            toggleCheckmark(cell.textLabel!.text!)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
}

extension String {
    func contains(find: String) -> Bool {
        return self.lowercaseString.hasPrefix(find.lowercaseString)
    }
}

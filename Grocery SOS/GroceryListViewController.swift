//
//  GroceryListViewController.swift
//  Grocery SOS
//
//  Created by Prithvi Rajesh Lalla on 2/24/16.
//  Copyright © 2016 Grocery SOS. All rights reserved.
//

import UIKit

class GroceryListViewController: UIViewController, RoutePreviewViewControllerDelegate, CategoryPreferenceViewControllerDelegate, ManagerViewControllerDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchTable: UITableView!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    var items = [GroceryItem]()
    var searchResults = [GroceryItem]()
    var checkedItems = [GroceryItem]()
    var categories = [String]()
    var hasSearched = false
    let emptySearchMessage = "(Nothing found)"
    var isLoading = false
    var dataTask: NSURLSessionDataTask?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        doneButton.enabled = false
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        items.sortInPlace({(item1: GroceryItem, item2: GroceryItem) -> Bool in item1.name < item2.name})
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
        checkedItems.sortInPlace({(item1: GroceryItem, item2: GroceryItem) -> Bool in item1.name < item2.name})
        doneButton.enabled = (!hasSearched && checkedItems.count > 0)
    }
    
    func removeCheckedItem(target: GroceryItem) {
        for i in 0...(checkedItems.count - 1) {
            if checkedItems[i] == target {
                checkedItems.removeAtIndex(i)
                break
            }
        }
    }
    
    func constructCategories(searchArray: [GroceryItem]) {
        categories.removeAll(keepCapacity: false)
        for item in searchArray {
            if !categories.contains(item.category) {
                categories.append(item.category)
            }
        }
        categories.sortInPlace()
    }
    
    func numberOfRowsPerSection(searchArray: [GroceryItem], section: Int) -> Int {
        var count = 0
        for item in searchArray {
            if item.category == categories[section] {
                count++
            }
        }
        return count
    }
    
    func positionInArray(searchArray: [GroceryItem], indexPath: NSIndexPath) -> Int {
        let category = categories[indexPath.section]
        var positions = [Int]()
        for i in 0...(searchArray.count - 1) {
            if category == searchArray[i].category {
                positions.append(i)
            }
        }
        return positions[indexPath.row]
    }
    
    func routePreviewViewControllerDidCancel(controller: RoutePreviewViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func categoryPreferenceViewControllerCancel(controller: CategoryPreferenceViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func categoryPreferenceViewControllerSave(controller: CategoryPreferenceViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func managerMode() {
        performSegueWithIdentifier("managerMode", sender: nil)
    }
    
    func managerViewControllerDelegateBack(controller: ManagerViewController) {
        dismissViewControllerAnimated(true, completion: nil)
        loadData()
    }
    
    func documentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        return paths[0]
    }
    
    func dataFilePath() -> String {
        return (documentsDirectory() as NSString).stringByAppendingPathComponent("GrocerySOSManager.plist")
    }
    
    func loadData() {
        let path = dataFilePath()
        if NSFileManager.defaultManager().fileExistsAtPath(path) {
            if let data = NSData(contentsOfFile: path) {
                let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
                items = unarchiver.decodeObjectForKey("managerInventory") as! [GroceryItem]
            }
        }
    }
    
    func urlWithSearchText(searchText: String) -> NSURL {
        let escapedSearchText = searchText.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let urlString = String(format: "https://itunes.apple.com/search?term=%@", escapedSearchText)
        let url = NSURL(string: urlString)
        return url!
    }
    
    func parseJSON(data: NSData) -> [String:AnyObject]? {
        do {
            return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String:AnyObject]
        } catch {
            print("JSON Error \(error)")
            return nil
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "routePreview" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! RoutePreviewViewController
            controller.delegate = self
        } else if segue.identifier == "editCategory" {
            let title = sender as! String
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! CategoryPreferenceViewController
            controller.delegate = self
            controller.category = title
        } else if segue.identifier == "managerMode" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! ManagerViewController
            controller.delegate = self
        }
    }

}

extension GroceryListViewController: UISearchBarDelegate {
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText != "" {
            hasSearched = true
            isLoading = true
            dataTask?.cancel()
            searchTable.reloadData()

            let url = self.urlWithSearchText(searchText)
            let session = NSURLSession.sharedSession()
            dataTask = session.dataTaskWithURL(url, completionHandler: {data, response, error in
                if let error = error where error.code == -999 {
                    return
                } else if let httpResponse = response as? NSHTTPURLResponse where httpResponse.statusCode == 200 {
                    if let data = data {
                        var dictionary = self.parseJSON(data)
                        dictionary?.removeAll(keepCapacity: false)
                        dispatch_async(dispatch_get_main_queue()) {
                            self.isLoading = false
                            self.searchResults.removeAll(keepCapacity: false)
                            for item in self.items {
                                if item.name.contains(searchBar.text!) {
                                    self.searchResults.append(item)
                                }
                            }
                            self.searchResults.sortInPlace({(item1: GroceryItem, item2: GroceryItem) -> Bool in item1.name < item2.name})
                            self.searchTable.reloadData()
                        }
                        return
                    }
                } else {
                        print("Failure \(response!)")
                    }
                })
            dataTask?.resume()
        } else {
            hasSearched = false
            searchResults.removeAll(keepCapacity: false)
            searchTable.reloadData()
        }
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
        let cellIdentifier = isLoading ? "LoadingViewCell" : "TableViewCell"
        let cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        if isLoading {
            let activityIndicator = cell.viewWithTag(100) as? UIActivityIndicatorView
            activityIndicator?.startAnimating()
            return cell
        }
        if hasSearched {
            if searchResults.count == 0 {
                cell.textLabel!.text = emptySearchMessage
            } else {
                let position = positionInArray(searchResults, indexPath: indexPath)
                cell.textLabel!.text = searchResults[position].name
                if searchResults[position].checkmark {
                    cell.accessoryType = .Checkmark
                } else {
                    cell.accessoryType = .None
                }
            }
        } else {
            let position = positionInArray(checkedItems, indexPath: indexPath)
            cell.textLabel!.text = checkedItems[position].name
            cell.accessoryType = .Checkmark
        }
        doneButton.enabled = (!hasSearched && checkedItems.count > 0)
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 1
        }
        if hasSearched {
            if searchResults.count == 0 {
                return 1
            } else {
                return numberOfRowsPerSection(searchResults, section: section)
            }
        } else {
            return numberOfRowsPerSection(checkedItems, section: section)
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if isLoading {
            return 1
        }
        if hasSearched {
            if searchResults.count == 0 {
                return 1
            } else {
                constructCategories(searchResults)
                return categories.count
            }
        } else {
            constructCategories(checkedItems)
            return categories.count < 1 ? 1 : categories.count
        }
    }

}

extension GroceryListViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if isLoading {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        } else {
            let cell = tableView.cellForRowAtIndexPath(indexPath)!
            if cell.textLabel!.text != emptySearchMessage {
                toggleCheckmark(cell.textLabel!.text!)
            }
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            tableView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if isLoading {
            return nil
        }
        let cellIdentifier = "HeaderViewCell"
        let cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        if categories.count != 0 && !(searchResults.count == 0 && hasSearched) {
            cell.textLabel!.text = categories[section]
            cell.textLabel!.textColor = UIColor.whiteColor()
            cell.accessoryType = hasSearched ? .None : .DetailDisclosureButton
            return cell
        }
        return nil
    }
    
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("editCategory", sender: categories[indexPath.section])
    }
    
    
}

extension String {
    
    func contains(find: String) -> Bool {
        return self.lowercaseString.hasPrefix(find.lowercaseString)
    }
    
}

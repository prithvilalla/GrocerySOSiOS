//
//  GroceryListViewController.swift
//  Grocery SOS
//
//  Created by Prithvi Rajesh Lalla on 2/24/16.
//  Copyright © 2016 Grocery SOS. All rights reserved.
//

import UIKit
import CoreLocation

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
    let serverUrl = "https://grocery-sos.herokuapp.com"
    let username = "testmanager"
    let password = "testmanager"
    var token: String!
    var userId: Int!
    let locationManager = CLLocationManager()
    var newLocation: CLLocation?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadData()
        isLoading = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        doneButton.enabled = false
        getLocation()
        getToken()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        items.sortInPlace({(item1: GroceryItem, item2: GroceryItem) -> Bool in item1.name < item2.name})
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clearGroceryItem(sender: UIBarButtonItem) {
        resetGroceryItem()
    }
    
    func resetGroceryItem() {
        for item in items {
            item.checkmark = false
        }
        searchResults.removeAll(keepCapacity: false)
        checkedItems.removeAll(keepCapacity: false)
        categories.removeAll(keepCapacity: false)
        hasSearched = false
        dataTask?.cancel()
        isLoading = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        doneButton.enabled = false
        searchTable.reloadData()
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
    
    func managerViewControllerBack(controller: ManagerViewController) {
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
        let urlString = String(format: "%@%@", serverUrl, escapedSearchText)
        let url = NSURL(string: urlString)
        return url!
    }
    
    func parseJSON(data: NSData) -> [String:AnyObject]? {
        do {
            return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String:AnyObject]
        } catch {
            print("parseJSON \(error)")
            return nil
        }
    }
    
    func showNetworkError() {
        let alert = UIAlertController(title: "Error", message: "There seems to be a connectivity issue. Please try again.", preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: {alert in self.resetGroceryItem()})
        alert.addAction(action)
        presentViewController(alert, animated: false, completion: nil)
    }
    
    func getToken() {
        let url: NSURL! = NSURL(string: "\(serverUrl)/api/token/local")
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        let parameters: [String: String] = ["username":"\(username)", "password":"\(password)"]
        do {
            try request.HTTPBody = NSJSONSerialization.dataWithJSONObject(parameters, options: [])
        } catch {
            print("Error HTTP POST Body")
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error in
            if let error = error {
                print("getToken Error \(error)")
                return
            } else if let httpResponse = response as? NSHTTPURLResponse where httpResponse.statusCode == 200 {
                if let data = data {
                    let dictionary = self.parseJSON(data)
                    self.token = dictionary!["token"] as! String
                    print("Token \(self.token)")
                    dispatch_async(dispatch_get_main_queue()) {
                        self.getUserId()
                    }
                }
                return
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.showNetworkError()
                    print("getToken Failure \(response)")
                }
                return
            }
        })
        task.resume()
    }
    
    func getUserId() {
        let url: NSURL! = NSURL(string: "\(serverUrl)/api/user")
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("JWT \(token)", forHTTPHeaderField: "Authorization")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error in
            if let error = error {
                print("getUserId Error \(error)")
                return
            } else if let httpResponse = response as? NSHTTPURLResponse where httpResponse.statusCode == 200 {
                if let data = data {
                    let dictionary = self.parseJSON(data)
                    self.userId = dictionary!["id"] as! Int
                    print("UserId \(self.userId)")
                    dispatch_async(dispatch_get_main_queue()) {
                        self.isLoading = false
                        self.searchTable.reloadData()
                    }
                }
                return
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.showNetworkError()
                    print("getUserId Failure \(response)")
                }
                return
            }
        })
        task.resume()
    }
    
    func getLocation() {
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .NotDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if authStatus == .Denied || authStatus == .Restricted {
            let alert = UIAlertController(title: "Location Services Disable", message: "Please enable location services for this app in Settings.", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(okAction)
            presentViewController(alert, animated: true, completion: nil)
        }
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
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
        dataTask?.cancel()
        if searchText != "" {
            hasSearched = true
            isLoading = true
            searchTable.reloadData()

            let url = urlWithSearchText(String(format: "/api/user/available/%@", searchText))
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "GET"
            let session = NSURLSession.sharedSession()
            dataTask = session.dataTaskWithRequest(request, completionHandler: {data, response, error in
            //dataTask = session.dataTaskWithURL(url, completionHandler: {data, response, error in
                if let error = error where error.code == -999 {
                    print("Error Code -999")
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
                    dispatch_async(dispatch_get_main_queue()) {
                        self.showNetworkError()
                        print("Failure \(response)")
                    }
                    return
                }
            })
            dataTask?.resume()
        } else {
            hasSearched = false
            isLoading = false
            searchResults.removeAll(keepCapacity: false)
            searchTable.reloadData()
        }
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        dataTask?.cancel()
        searchBar.text = ""
        hasSearched = false
        isLoading = false
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
                cell.accessoryType = .None
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

extension GroceryListViewController: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("locationManager didFailWithError \(error)")
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        newLocation = locations.last!
        print("locationManager didUpdateLocations latitude \(newLocation?.coordinate.latitude)")
        print("locationManager didUpdateLocations longitude \(newLocation?.coordinate.longitude)")
        stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        print("locationManager didChangeAuthorizationStatus \(status)")
    }
    
}

extension String {
    
    func contains(find: String) -> Bool {
        return self.lowercaseString.hasPrefix(find.lowercaseString)
    }
    
}

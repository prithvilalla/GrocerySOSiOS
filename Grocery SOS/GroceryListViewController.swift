//
//  GroceryListViewController.swift
//  Grocery SOS
//
//  Created by Prithvi Rajesh Lalla on 2/24/16.
//  Copyright © 2016 Grocery SOS. All rights reserved.
//

import UIKit
import CoreLocation

class GroceryListViewController: UIViewController, RoutePreviewViewControllerDelegate, CategoryPreferenceViewControllerDelegate, ManagerViewControllerDelegate, ProfileViewControllerDelegate, LoginViewControllerDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchTable: UITableView!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var managerButton: UIBarButtonItem!
    @IBOutlet weak var profileButton: UIBarButtonItem!
    @IBOutlet weak var logButton: UIBarButtonItem!
    
    var categoriesList = [Int: String]()
    var items = [GroceryItem]()
    var searchResults = [GroceryItem]()
    var checkedItems = [GroceryItem]()
    var categories = [String]()
    var hasSearched = false
    let emptySearchMessage = "(Nothing found)"
    var isLoading = false
    let serverUrl = "https://grocery-sos.herokuapp.com"
    var username: String?
    var password: String?
    var user: User?
    var token: String!
    var store: Store?
    let locationManager = CLLocationManager()
    var newLocation: CLLocation?
    var hasLocation = false
    var isLoggedIn: Bool!
    var refreshControl: UIRefreshControl!
    var timer: NSTimer!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        searchTable.addSubview(refreshControl)
        doneButton.enabled = false
        managerButton.enabled = false
        logButton.enabled = false
        profileButton.enabled = false
        loadLoginData()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        if username == nil {
            isLoggedIn = false
            logButton.title = "Login"
            logButton.enabled = true
            performSegueWithIdentifier("login", sender: nil)
        } else {
            isLoggedIn = true
            getLocation()
            getToken()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clearGroceryItem(sender: UIBarButtonItem) {
        resetGroceryItem()
    }
    
    func resetGroceryItem() {
        isLoading = true
        searchTable.reloadData()
        let url: NSURL! = NSURL(string: "\(serverUrl)/api/list")
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "DELETE"
        request.addValue("JWT \(token)", forHTTPHeaderField: "Authorization")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error in
            if let error = error {
                self.isLoading = false
                self.searchTable.reloadData()
                print("resetGroceryItem Error \(error)")
                return
            } else if let httpResponse = response as? NSHTTPURLResponse where httpResponse.statusCode == 200 {
                dispatch_async(dispatch_get_main_queue()) {
                    for item in self.items {
                        item.checkmark = false
                    }
                    self.searchResults.removeAll(keepCapacity: false)
                    self.checkedItems.removeAll(keepCapacity: false)
                    self.categories.removeAll(keepCapacity: false)
                    self.hasSearched = false
                    self.isLoading = false
                    self.searchBar.text = ""
                    self.searchBar.resignFirstResponder()
                    self.doneButton.enabled = false
                    self.searchTable.reloadData()
                }
                return
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.isLoading = false
                    self.searchTable.reloadData()
                    self.showNetworkError()
                    print("resetGroceryItem Failure \(response)")
                }
                return
            }
        })
        task.resume()
    }
    
    func toggleCheckmark(name: String, addItem: Bool = true) {
        for item in items {
            if item.name == name {
                if item.checkmark {
                    item.checkmark = false
                    removeCheckedItem(item)
                    if addItem {
                        listDeleteItem(item.name)
                    }
                } else {
                    item.checkmark = true
                    checkedItems.append(item)
                    if addItem {
                        listAddItem(item.name)
                    }
                }
            }
        }
        checkedItems.sortInPlace({(item1: GroceryItem, item2: GroceryItem) -> Bool in item1.name < item2.name})
        doneButton.enabled = (!hasSearched && checkedItems.count > 0 && !isLoading && hasLocation)
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
                count += 1
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
    
    @IBAction func logout(sender: UIBarButtonItem) {
        username = nil
        password = nil
        saveLoginData()
        performSegueWithIdentifier("login", sender: nil)
    }
    
    @IBAction func profile(sender: UIBarButtonItem) {
        performSegueWithIdentifier("profile", sender: nil)
    }
    
    @IBAction func managerMode() {
        performSegueWithIdentifier("managerMode", sender: nil)
    }
    
    func managerViewControllerBack(controller: ManagerViewController) {
        dismissViewControllerAnimated(true, completion: nil)
        itemGetAll()
    }
    
    func profileViewControllerCancel(controller: ProfileViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func profileViewControllerSave(controller: ProfileViewController) {
        dismissViewControllerAnimated(true, completion: nil)
        let newUsername = controller.usernameTextField.text!
        let newPassword = controller.password
        let newEmail = controller.emailTextField.text!
        let newPhone = controller.phoneTextField.text!
        let newStoreManager = controller.storeManagerSwitch.on
        if newUsername != username {
            userAvailable(newUsername, newPassword: newPassword, newEmail: newEmail, newPhone: newPhone, newStoreManager: newStoreManager)
        } else {
            userEdit(newUsername, newPassword: newPassword, newEmail: newEmail, newPhone: newPhone, newStoreManager: newStoreManager)
        }
    }
    
    func loginViewControllerLogin(controller: LoginViewController) {
        dismissViewControllerAnimated(true, completion: nil)
        username = controller.username!
        password = controller.password!
        saveLoginData()
        getLocation()
        getToken()
    }
    
    func documentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        return paths[0]
    }
    
    func dataFilePath() -> String {
        return (documentsDirectory() as NSString).stringByAppendingPathComponent("GrocerySOS.plist")
    }
    
    func saveLoginData() {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        archiver.encodeObject(username, forKey: "username")
        archiver.encodeObject(password, forKey: "password")
        archiver.finishEncoding()
        data.writeToFile(dataFilePath(), atomically: true)
    }
    
    func loadLoginData() {
        let path = dataFilePath()
        if NSFileManager.defaultManager().fileExistsAtPath(path) {
            if let data = NSData(contentsOfFile: path) {
                let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
                username = unarchiver.decodeObjectForKey("username") as? String
                password = unarchiver.decodeObjectForKey("password") as? String
            }
        }
    }
    
    func loadData(data: [String:AnyObject]) {
        items.removeAll(keepCapacity: false)
        let allItems = data["items"] as! [AnyObject]
        for item in allItems {
            let name = item["name"] as! String
            let category1 = item["category"] as! Int
            let category = categoriesList[category1]!
            let descript = item["description"] as! String
            let id = item["id"] as! Int
            items.append(GroceryItem(name: name, category: category, descript: descript, id: id))
        }
        items.sortInPlace({(item1: GroceryItem, item2: GroceryItem) -> Bool in item1.name < item2.name})
    }
    
    /*func urlWithSearchText(searchText: String) -> NSURL {
        let escapedSearchText = searchText.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let urlString = String(format: "%@%@", serverUrl, escapedSearchText)
        let url = NSURL(string: urlString)
        return url!
    }*/
    
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
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: false, completion: nil)
    }
    
    func showUsernameError() {
        let alert = UIAlertController(title: "Error", message: "There seems to be a username issue. Please try again or another username.", preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: false, completion: nil)
    }
    
    func getToken() {
        isLoading = true
        searchTable.reloadData()
        let url: NSURL! = NSURL(string: "\(serverUrl)/api/token/local")
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        let parameters: [String: String] = ["username":"\(username!)", "password":"\(password!)"]
        do {
            try request.HTTPBody = NSJSONSerialization.dataWithJSONObject(parameters, options: [])
        } catch {
            print("Error HTTP POST Body")
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error in
            if let error = error {
                self.isLoading = false
                self.searchTable.reloadData()
                print("getToken Error \(error)")
                return
            } else if let httpResponse = response as? NSHTTPURLResponse where httpResponse.statusCode == 200 {
                if let data = data {
                    let dictionary = self.parseJSON(data)
                    self.token = dictionary!["token"] as! String
                    dispatch_async(dispatch_get_main_queue()) {
                        self.getUserInfo()
                    }
                }
                return
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.isLoading = false
                    self.searchTable.reloadData()
                    self.showNetworkError()
                    print("getToken Failure \(response)")
                }
                return
            }
        })
        task.resume()
    }
    
    func getUserInfo() {
        isLoading = true
        searchTable.reloadData()
        let url: NSURL! = NSURL(string: "\(serverUrl)/api/user")
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("JWT \(token)", forHTTPHeaderField: "Authorization")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error in
            if let error = error {
                self.isLoading = false
                self.searchTable.reloadData()
                print("getUserId Error \(error)")
                return
            } else if let httpResponse = response as? NSHTTPURLResponse where httpResponse.statusCode == 200 {
                if let data = data {
                    let dictionary = self.parseJSON(data)
                    let email = dictionary!["email"] as! String
                    let phone = dictionary!["phone"] as! String
                    let isManager = dictionary!["isManager"] as! Bool
                    self.user = User(username: self.username!, email: email, phone: phone, isManager: isManager)
                    if self.user!.isManager {
                        let stores = dictionary!["stores"] as? [AnyObject]
                        if stores?.count != 0 {
                            let store = stores?[0] as? [String: AnyObject]
                            let storeId = store?["id"] as! Int
                            let storeName = store?["name"] as! String
                            let address = store?["address"] as? [String: AnyObject]
                            let storeStreet = address?["street"] as! String
                            let storeCity = address?["city"] as! String
                            let storeState = address?["state"] as! String
                            let storeZip = address?["zip"] as! String
                            self.store = Store(id: storeId, name: storeName, street: storeStreet, city: storeCity, state: storeState, zip: storeZip)
                        }
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        self.categoryGetAll()
                    }
                }
                return
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.isLoading = false
                    self.searchTable.reloadData()
                    self.showNetworkError()
                    print("getUserId Failure \(response)")
                }
                return
            }
        })
        task.resume()
    }
    
    func userAvailable(newUsername: String, newPassword: String, newEmail: String, newPhone: String, newStoreManager: Bool, edit: Bool = true) {
        isLoading = true
        searchTable.reloadData()
        let url: NSURL! = NSURL(string: "\(serverUrl)/api/user/available/\(newUsername)")
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error in
            if let error = error {
                self.isLoading = false
                self.searchTable.reloadData()
                print("userAvailable Error \(error)")
                return
            } else if let httpResponse = response as? NSHTTPURLResponse where httpResponse.statusCode == 200 {
                if let data = data {
                    let dictionary = self.parseJSON(data)
                    let available = dictionary!["available"] as! Bool
                    dispatch_async(dispatch_get_main_queue()) {
                        if !available {
                            self.isLoading = false
                            self.searchTable.reloadData()
                            self.showUsernameError()
                        } else if edit{
                            self.userEdit(newUsername, newPassword: newPassword, newEmail: newEmail, newPhone: newPhone, newStoreManager: newStoreManager)
                        }
                    }
                }
                return
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.isLoading = false
                    self.searchTable.reloadData()
                    self.showNetworkError()
                    print("userAvailable Failure \(response)")
                }
                return
            }
        })
        task.resume()
    }
    
    func userEdit(newUsername: String, newPassword: String, newEmail: String, newPhone: String, newStoreManager: Bool) {
        isLoading = true
        searchTable.reloadData()
        let url: NSURL! = NSURL(string: "\(serverUrl)/api/user/edit")
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("JWT \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let parameters: [String: AnyObject] = ["username": "\(newUsername)", "password": "\(newPassword)", "email": "\(newEmail)", "phone": "\(newPhone)", "isManager": newStoreManager]
        do {
            try request.HTTPBody = NSJSONSerialization.dataWithJSONObject(parameters, options: [])
        } catch {
            print("Error HTTP POST Body")
        }
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error in
            if let error = error {
                self.isLoading = false
                self.searchTable.reloadData()
                print("userEdit Error \(error)")
                return
            } else if let httpResponse = response as? NSHTTPURLResponse where httpResponse.statusCode == 200 {
                dispatch_async(dispatch_get_main_queue()) {
                    self.username = newUsername
                    self.password = newPassword
                    self.saveLoginData()
                    self.getToken()
                }
                return
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.isLoading = false
                    self.searchTable.reloadData()
                    self.showNetworkError()
                    print("userEdit Failure \(response)")
                }
                return
            }
        })
        task.resume()
    }
    
    func categoryGetAll() {
        isLoading = true
        searchTable.reloadData()
        categoriesList.removeAll(keepCapacity: false)
        let url: NSURL! = NSURL(string: "\(serverUrl)/api/category/all")
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error in
            if let error = error {
                self.isLoading = false
                self.searchTable.reloadData()
                print("categoryGetAll Error \(error)")
            } else if let httpResponse = response as? NSHTTPURLResponse where httpResponse.statusCode == 200 {
                if let data = data {
                    let dictionary = self.parseJSON(data)
                    let categoryArray = dictionary!["categories"] as! [AnyObject]
                    for i in 0...(categoryArray.count - 1) {
                        let category = categoryArray[i] as! [String: AnyObject]
                        let id = category["id"] as! Int
                        let name = category["name"] as! String
                        self.categoriesList[id] = name
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        self.itemGetAll()
                    }
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.isLoading = false
                    self.searchTable.reloadData()
                    self.showNetworkError()
                    print("categoryGetAll Failure \(response)")
                }
            }
        })
        task.resume()
    }
    
    func itemGetAll() {
        isLoading = true
        searchTable.reloadData()
        items.removeAll(keepCapacity: false)
        searchResults.removeAll(keepCapacity: false)
        checkedItems.removeAll(keepCapacity: false)
        let url: NSURL! = NSURL(string: "\(serverUrl)/api/item/getAll")
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("JWT \(token)", forHTTPHeaderField: "Authorization")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error in
            if let error = error {
                self.isLoading = false
                self.searchTable.reloadData()
                print("itemGetAll Error \(error)")
                return
            } else if let httpResponse = response as? NSHTTPURLResponse where httpResponse.statusCode == 200 {
                if let data = data {
                    let dictionary = self.parseJSON(data)
                    self.loadData(dictionary!)
                    dispatch_async(dispatch_get_main_queue()) {
                        self.listGetItems()
                    }
                    return
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.isLoading = false
                    self.searchTable.reloadData()
                    self.showNetworkError()
                    print("itemGetAll Failure \(response)")
                }
                return
            }
        })
        task.resume()
    }
    
    func listGetItems() {
        isLoading = true
        searchTable.reloadData()
        let url: NSURL! = NSURL(string: "\(serverUrl)/api/list/getItems")
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("JWT \(token)", forHTTPHeaderField: "Authorization")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error in
            if let error = error {
                self.isLoading = false
                self.searchTable.reloadData()
                print("listGetItems Error \(error)")
                return
            } else if let httpResponse = response as? NSHTTPURLResponse where httpResponse.statusCode == 200 {
                if let data = data {
                    let dictionary = self.parseJSON(data)
                    let itemList = dictionary!["items"] as! [AnyObject]
                    for item in itemList {
                        let name = item["name"] as! String
                        self.toggleCheckmark(name, addItem: false)
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        self.isLoading = false
                        self.logButton.title = "Logout"
                        self.logButton.enabled = true
                        self.profileButton.enabled = true
                        self.searchTable.reloadData()
                        self.managerButton.enabled = self.user!.isManager
                    }
                    return
                }
            } else {
                self.isLoading = false
                self.searchTable.reloadData()
                dispatch_async(dispatch_get_main_queue()) {
                    self.showNetworkError()
                    print("itemGetAll Failure \(response)")
                }
                return
            }
        })
        task.resume()
    }
    
    func listAddItem(name: String) {
        isLoading = true
        searchTable.reloadData()
        let url: NSURL! = NSURL(string: "\(serverUrl)/api/list/addItem")
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("JWT \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let parameters: [String: String] = ["item":"\(name)"]
        do {
            try request.HTTPBody = NSJSONSerialization.dataWithJSONObject(parameters, options: [])
        } catch {
            print("Error HTTP POST Body")
        }
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error in
            if let error = error {
                self.isLoading = false
                self.searchTable.reloadData()
                print("listGetItems Error \(error)")
                return
            } else if let httpResponse = response as? NSHTTPURLResponse where httpResponse.statusCode == 200 {
                dispatch_async(dispatch_get_main_queue()) {
                    self.isLoading = false
                    self.searchTable.reloadData()
                }
                return
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.isLoading = false
                    self.searchTable.reloadData()
                    self.showNetworkError()
                    print("itemGetAll Failure \(response)")
                }
                return
            }
        })
        task.resume()
    }
    
    func listDeleteItem(name: String) {
        isLoading = true
        searchTable.reloadData()
        let url: NSURL! = NSURL(string: "\(serverUrl)/api/list/deleteItem")
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("JWT \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let parameters: [String: String] = ["item":"\(name)"]
        do {
            try request.HTTPBody = NSJSONSerialization.dataWithJSONObject(parameters, options: [])
        } catch {
            print("Error HTTP POST Body")
        }
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error in
            if let error = error {
                self.isLoading = false
                self.searchTable.reloadData()
                print("listGetItems Error \(error)")
                return
            } else if let httpResponse = response as? NSHTTPURLResponse where httpResponse.statusCode == 200 {
                dispatch_async(dispatch_get_main_queue()) {
                    self.isLoading = false
                    self.searchTable.reloadData()
                }
                return
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.isLoading = false
                    self.searchTable.reloadData()
                    self.showNetworkError()
                    print("itemGetAll Failure \(response)")
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
            showGPSError()
        }
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func showGPSError() {
        let alert = UIAlertController(title: "Location Services Disable", message: "Please enable location services for this app in Settings.", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(okAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
    }
    
    func startRefresh() {
        getLocation()
        getToken()
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(GroceryListViewController.endRefresh), userInfo: nil, repeats: true)
    }
    
    func endRefresh() {
        refreshControl.endRefreshing()
        timer.invalidate()
        timer = nil
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if refreshControl.refreshing {
            startRefresh()
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
            controller.myGPS = newLocation!
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
            controller.user = user!
            controller.token = token
            controller.store = store!
            controller.serverUrl = serverUrl
            controller.categoriesList = categoriesList
        } else if segue.identifier == "profile" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! ProfileViewController
            controller.delegate = self
            controller.username = username!
            controller.password = password!
            controller.user = user!
        } else if segue.identifier == "login" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! LoginViewController
            controller.delegate = self
            controller.serverUrl = serverUrl
        }
    }

}

extension GroceryListViewController: UISearchBarDelegate {
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText != "" {
            hasSearched = true
            searchResults.removeAll(keepCapacity: false)
            for item in items {
                if item.name.contains(searchBar.text!) {
                    searchResults.append(item)
                }
            }
            searchResults.sortInPlace({(item1: GroceryItem, item2: GroceryItem) -> Bool in item1.name < item2.name})
            searchTable.reloadData()
        } else {
            hasSearched = false
            isLoading = false
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
        doneButton.enabled = (!hasSearched && checkedItems.count > 0 && !isLoading && hasLocation)
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
        if error.code != 0 && error.domain != "kCLErrorDomain" {
            print("locationManager didFailWithError \(error)")
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        newLocation = locations.last!
        hasLocation = true
        stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    }
    
}

extension String {
    
    func contains(find: String) -> Bool {
        return self.lowercaseString.hasPrefix(find.lowercaseString)
    }
    
}

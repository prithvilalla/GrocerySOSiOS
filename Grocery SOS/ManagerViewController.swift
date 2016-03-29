//
//  ManagerViewController.swift
//  Grocery SOS
//
//  Created by Prithvi Rajesh Lalla on 2/28/16.
//  Copyright © 2016 Grocery SOS. All rights reserved.
//

import UIKit

protocol ManagerViewControllerDelegate: class {
    func managerViewControllerBack(controller: ManagerViewController)
}

class ManagerViewController: UIViewController, ManagerModifyViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameButton: UIButton!
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var streetButton: UIButton!
    @IBOutlet weak var cityButton: UIButton!
    @IBOutlet weak var stateButton: UIButton!
    @IBOutlet weak var zipButton: UIButton!
    var categoriesList: [Int: String]!
    var information = [String: String]()
    var inventory = [GroceryItem]()
    var categories = [String]()
    var token: String!
    var Name: String?
    var Phone: String?
    var StreetAddress: String?
    var City: String?
    var State: String?
    var Zip: String?
    var serverUrl: String!
    var isLoading = false
    
    
    weak var delegate: ManagerViewControllerDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        isLoading = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        if information.count == 0 {
            information["Name"] = "BLANK"
            information["Phone"] = "BLANK"
            information["Street Address"] = "BLANK"
            information["City"] = "BLANK"
            information["State"] = "BLANK"
            information["Zip"] = "BLANK"
        }
        
        if let Name = Name {
            information["Name"] = Name
        }
        if let Phone = Phone {
            information["Phone"] = Phone
        }
        if let StreetAddress = StreetAddress {
            information["Street Address"] = StreetAddress
        }
        if let City = City {
            information["City"] = City
        }
        if let State = State {
            information["State"] = State
        }
        if let Zip = Zip {
            information["Zip"] = Zip
        }
        itemGetAll()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        nameButton.setTitle(information["Name"], forState: UIControlState.Normal)
        phoneButton.setTitle(information["Phone"], forState: UIControlState.Normal)
        streetButton.setTitle(information["Street Address"], forState: UIControlState.Normal)
        cityButton.setTitle(information["City"], forState: UIControlState.Normal)
        stateButton.setTitle(information["State"], forState: UIControlState.Normal)
        zipButton.setTitle(information["Zip"], forState: UIControlState.Normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back() {
        delegate?.managerViewControllerBack(self)
    }
    
    func managerModifyViewControllerCancel(controller: ManagerModifyViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func managerModifyViewControllerSave(controller: ManagerModifyViewController) {
        dismissViewControllerAnimated(true, completion: nil)
        if !controller.addItem {
            information[controller.field] = controller.entry
        } else {
            let newItem = GroceryItem(name: controller.entry, category: controller.category!, descript: controller.descript)
            itemCreate(newItem)
        }
        tableView.reloadData()
    }
    
    @IBAction func nameEdit(sender: UIButton) {
        performSegueWithIdentifier("managerModify", sender: ["Name", information["Name"]!])
    }
    
    @IBAction func phoneEdit(sender: UIButton) {
        performSegueWithIdentifier("managerModify", sender: ["Phone", information["Phone"]!])
    }
    
    @IBAction func streetEdit(sender: UIButton) {
        performSegueWithIdentifier("managerModify", sender: ["Street Address", information["Street Address"]!])
    }
    
    @IBAction func cityEdit(sender: UIButton) {
        performSegueWithIdentifier("managerModify", sender: ["City", information["City"]!])
    }

    @IBAction func stateEdit(sender: UIButton) {
        performSegueWithIdentifier("managerModify", sender: ["State", information["State"]!])
    }
    
    @IBAction func zipEdit(sender: UIButton) {
        performSegueWithIdentifier("managerModify", sender: ["Zip", information["Zip"]!])
    }
    
    @IBAction func addItem(sender: UIBarButtonItem) {
        performSegueWithIdentifier("addItem", sender: nil)
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
    
    func documentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        return paths[0]
    }
    
    func dataFilePath() -> String {
        return (documentsDirectory() as NSString).stringByAppendingPathComponent("GrocerySOSManager.plist")
    }
    
    func loadData(data: [String:AnyObject]) {
        inventory.removeAll(keepCapacity: false)
        let items = data["items"] as! [AnyObject]
        for item in items {
            let name = item["name"] as! String
            let category1 = item["category"] as! Int
            let category = categoriesList[category1]!
            let descript = item["description"] as! String
            inventory.append(GroceryItem(name: name, category: category, descript: descript))
        }
        inventory.sortInPlace({(item1: GroceryItem, item2: GroceryItem) -> Bool in item1.name < item2.name})
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
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func itemGetAll() {
        isLoading = true
        tableView.reloadData()
        let url: NSURL! = NSURL(string: "\(serverUrl)/api/item/getAll")
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("JWT \(token)", forHTTPHeaderField: "Authorization")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error in
            if let error = error {
                self.isLoading = false
                self.tableView.reloadData()
                print("itemGetAll Error \(error)")
                return
            } else if let httpResponse = response as? NSHTTPURLResponse where httpResponse.statusCode == 200 {
                if let data = data {
                    let dictionary = self.parseJSON(data)
                    self.loadData(dictionary!)
                    dispatch_async(dispatch_get_main_queue()) {
                        self.isLoading = false
                        self.tableView.reloadData()
                    }
                    return
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.isLoading = false
                    self.tableView.reloadData()
                    self.showNetworkError()
                    print("itemGetAll Failure \(response)")
                }
                return
            }
        })
        task.resume()
    }
    
    func itemCreate(newItem: GroceryItem) {
        isLoading = true
        tableView.reloadData()
        let url: NSURL! = NSURL(string: "\(serverUrl)/api/item/create")
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("JWT \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let parameters: [String: String] = ["name": "\(newItem.name)", "description": "\(newItem.descript)", "category": "\(newItem.category)", "store": "\(information["Name"]!)"]
        do {
            try request.HTTPBody = NSJSONSerialization.dataWithJSONObject(parameters, options: [])
        } catch {
            print("Error HTTP POST Body")
        }
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error in
            if let error = error {
                self.isLoading = false
                self.tableView.reloadData()
                print("itemCreate Error \(error)")
                return
            } else if let httpResponse = response as? NSHTTPURLResponse where httpResponse.statusCode == 200 {
                dispatch_async(dispatch_get_main_queue()) {
                    self.isLoading = false
                    self.inventory.append(newItem)
                    self.inventory.sortInPlace({(item1: GroceryItem, item2: GroceryItem) -> Bool in item1.name < item2.name})
                    self.tableView.reloadData()
                }
                return
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.isLoading = false
                    self.tableView.reloadData()
                    self.showNetworkError()
                    print("itemCreate Failure \(response)")
                }
                return
            }
        })
        task.resume()
    }
    
    func itemDelete(position: Int) {
        isLoading = true
        tableView.reloadData()
        let deleteItem = inventory[position]
        let url: NSURL! = NSURL(string: "\(serverUrl)/api/item/delete")
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("JWT \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let parameters: [String: String] = ["item": "\(deleteItem.name)","store": "\(information["Name"]!)"]
        do {
            try request.HTTPBody = NSJSONSerialization.dataWithJSONObject(parameters, options: [])
        } catch {
            print("Error HTTP POST Body")
        }
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error in
            if let error = error {
                self.isLoading = false
                self.tableView.reloadData()
                print("itemDelete Error \(error)")
                return
            } else if let httpResponse = response as? NSHTTPURLResponse where httpResponse.statusCode == 200 {
                dispatch_async(dispatch_get_main_queue()) {
                    self.isLoading = false
                    self.inventory.removeAtIndex(position)
                    self.constructCategories(self.inventory)
                    self.tableView.reloadData()
                }
                return
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.isLoading = false
                    self.tableView.reloadData()
                    self.showNetworkError()
                    print("itemDelete Failure \(response)")
                }
                return
            }
        })
        task.resume()
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
        if segue.identifier == "managerModify" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! ManagerModifyViewController
            controller.delegate = self
            let info = sender as! [String]
            controller.field = info[0]
            controller.data = info[1]
            controller.addItem = false
        } else if segue.identifier == "addItem" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! ManagerModifyViewController
            controller.delegate = self
            controller.field = "Add Item"
            controller.data = ""
            controller.addItem = true
            var allCategories = [String]()
            for (_, name) in categoriesList {
                allCategories.append(name)
            }
            allCategories.sortInPlace()
            controller.categories = allCategories
        }
    }

}

extension ManagerViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if !isLoading {
            let cellIdentifier = "HeaderViewCell"
            let cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
            cell.textLabel!.text = categories[section]
            cell.textLabel!.textColor = UIColor.whiteColor()
            return cell
        }
        return nil
    }

}

extension ManagerViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = isLoading ? "LoadingViewCell" : "TableViewCell"
        let cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        if isLoading {
            let activityIndicator = cell.viewWithTag(100) as? UIActivityIndicatorView
            activityIndicator?.startAnimating()
            return cell
        }
        let position = positionInArray(inventory, indexPath: indexPath)
        cell.textLabel!.text = inventory[position].name
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isLoading ? 1 : numberOfRowsPerSection(inventory, section: section)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        constructCategories(inventory)
        return isLoading ? 1 : categories.count
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return !isLoading
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let position = positionInArray(inventory, indexPath: indexPath)
        itemDelete(position)
    }
    
}
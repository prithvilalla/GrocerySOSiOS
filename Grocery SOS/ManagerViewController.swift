//
//  ManagerViewController.swift
//  Grocery SOS
//
//  Created by Prithvi Rajesh Lalla on 2/28/16.
//  Copyright © 2016 Grocery SOS. All rights reserved.
//

import UIKit

protocol ManagerViewControllerDelegate: class {
    func managerViewControllerDelegateBack(controller: ManagerViewController)
}

class ManagerViewController: UIViewController, ManagerModifyViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameButton: UIButton!
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var streetButton: UIButton!
    @IBOutlet weak var cityButton: UIButton!
    @IBOutlet weak var stateButton: UIButton!
    @IBOutlet weak var zipButton: UIButton!
    var information = [String: String]()
    var inventory = [GroceryItem]()
    var categories = [String]()
    
    weak var delegate: ManagerViewControllerDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        loadData()
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

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        nameButton.setTitle(information["Name"], forState: UIControlState.Normal)
        phoneButton.setTitle(information["Phone"], forState: UIControlState.Normal)
        streetButton.setTitle(information["Street Address"], forState: UIControlState.Normal)
        cityButton.setTitle(information["City"], forState: UIControlState.Normal)
        stateButton.setTitle(information["State"], forState: UIControlState.Normal)
        zipButton.setTitle(information["Zip"], forState: UIControlState.Normal)
        
        inventory.sortInPlace({(item1: GroceryItem, item2: GroceryItem) -> Bool in item1.name < item2.name})
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back() {
        delegate?.managerViewControllerDelegateBack(self)
    }
    
    func managerModifyViewControllerCancel(controller: ManagerModifyViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func managerModifyViewControllerSave(controller: ManagerModifyViewController) {
        if !controller.addItem {
            information[controller.field] = controller.entry
        } else {
            inventory.append(GroceryItem(name: controller.entry, category: controller.category, descript: controller.descript))
            inventory.sortInPlace({(item1: GroceryItem, item2: GroceryItem) -> Bool in item1.name < item2.name})
        }
        dismissViewControllerAnimated(true, completion: nil)
        tableView.reloadData()
        saveData()
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
    
    func saveData() {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        archiver.encodeObject(inventory, forKey: "managerInventory")
        archiver.encodeObject(information, forKey: "managerInformation")
        archiver.finishEncoding()
        data.writeToFile(dataFilePath(), atomically: true)
    }
    
    func loadData() {
        let path = dataFilePath()
        if NSFileManager.defaultManager().fileExistsAtPath(path) {
            if let data = NSData(contentsOfFile: path) {
                let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
                inventory = unarchiver.decodeObjectForKey("managerInventory") as! [GroceryItem]
                information = unarchiver.decodeObjectForKey("managerInformation") as! [String:String]
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
        }
    }

}

extension ManagerViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cellIdentifier = "HeaderViewCell"
        let cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        cell.textLabel!.text = categories[section]
        cell.textLabel!.textColor = UIColor.whiteColor()
        return cell
    }

}

extension ManagerViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "TableViewCell"
        let cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        let position = positionInArray(inventory, indexPath: indexPath)
        cell.textLabel!.text = inventory[position].name
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRowsPerSection(inventory, section: section)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        constructCategories(inventory)
        return categories.count
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let position = positionInArray(inventory, indexPath: indexPath)
        inventory.removeAtIndex(position)
        constructCategories(inventory)
        tableView.reloadData()
        saveData()
    }
    
}
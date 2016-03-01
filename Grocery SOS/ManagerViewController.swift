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
    var name: String!
    var address1: String!
    var address2: String!
    var phoneNumber: String!
    
    weak var delegate: ManagerViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        name = "ABC XYZ"
        address1 = "123 DEF ST"
        address2 = "ATLANTA GA 12345"
        phoneNumber = "1234567890"
        self.automaticallyAdjustsScrollViewInsets = false

        // Do any additional setup after loading the view.
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
        dismissViewControllerAnimated(true, completion: nil)
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
        }
    }

}

extension ManagerViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("managerModify", sender: nil)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cellIdentifier = "HeaderViewCell"
        let cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        if section == 0 {
            cell.textLabel!.text = "Name"
        } else if section == 1 {
            cell.textLabel!.text = "Address 1"
        } else if section == 2 {
            cell.textLabel!.text = "Address 2"
        } else if section == 3 {
            cell.textLabel!.text = "Phone Number"
        }
        cell.textLabel!.textColor = UIColor.whiteColor()
        return cell
    }
    
    
}

extension ManagerViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "TableViewCell"
        let cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        if indexPath.section == 0 {
            cell.textLabel!.text = name
        } else if indexPath.section == 1 {
            cell.textLabel!.text = address2
        } else if indexPath.section == 2 {
            cell.textLabel!.text = address2
        } else if indexPath.section == 3 {
            cell.textLabel!.text = phoneNumber
        }
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
}
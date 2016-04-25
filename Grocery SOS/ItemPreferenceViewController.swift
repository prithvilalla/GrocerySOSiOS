//
//  ItemPreferenceViewController.swift
//  Grocery SOS
//
//  Created by Prithvi Rajesh Lalla on 2/28/16.
//  Copyright © 2016 Grocery SOS. All rights reserved.
//

import UIKit

protocol ItemPreferenceViewControllerDelegate: class {
    func itemPreferenceViewControllerCancel(controller: ItemPreferenceViewController)
    func itemPreferenceViewControllerSave(controller: ItemPreferenceViewController)
}

class ItemPreferenceViewController: UIViewController {
    
    var item: GroceryItem!
    weak var delegate: ItemPreferenceViewControllerDelegate?
    var stores: [Store]!
    var current: Store?
    var selected: Store?
    let errorMessage = "No stores found for item"
    
    @IBOutlet weak var setDefault: UISwitch!
    @IBOutlet weak var storeTable: UITableView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = item.name
        self.automaticallyAdjustsScrollViewInsets = false
        if selected == nil {
            saveButton.enabled = false
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        if current != nil {
            selected = current
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel() {
        delegate?.itemPreferenceViewControllerCancel(self)
    }
    
    @IBAction func save() {
        delegate?.itemPreferenceViewControllerSave(self)
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

extension ItemPreferenceViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if stores.count != 0 {
            if selected == stores[indexPath.row] {
                selected = nil
                saveButton.enabled = false
            } else {
                selected = stores[indexPath.row]
                saveButton.enabled = true
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        storeTable.reloadData()
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cellIdentifier = "HeaderViewCell"
        let cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        cell.textLabel!.text = "Store Options"
        cell.textLabel!.textColor = UIColor.whiteColor()
        return cell
    }
    
}

extension ItemPreferenceViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "TableViewCell"
        let cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        if stores.count == 0 {
            cell.textLabel!.text = errorMessage
            cell.accessoryType = .None
        } else {
            cell.textLabel!.text = "\(indexPath.row + 1). \(stores[indexPath.row].name)"
            if selected == stores[indexPath.row] {
                cell.accessoryType = .Checkmark
            } else {
                cell.accessoryType = .None
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if stores.count == 0 {
            return 1
        }
        return stores.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
}
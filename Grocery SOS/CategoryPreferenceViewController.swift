//
//  CategoryPreferenceViewController.swift
//  Grocery SOS
//
//  Created by Prithvi Rajesh Lalla on 2/28/16.
//  Copyright © 2016 Grocery SOS. All rights reserved.
//

import UIKit

protocol CategoryPreferenceViewControllerDelegate: class {
    func categoryPreferenceViewControllerCancel(controller: CategoryPreferenceViewController)
    func categoryPreferenceViewControllerSave(controller: CategoryPreferenceViewController)
}

class CategoryPreferenceViewController: UIViewController {
    
    var category: String?
    weak var delegate: CategoryPreferenceViewControllerDelegate?
    var stores = [String]()
    var current = String()
    @IBOutlet weak var storeTable: UITableView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        for i in 1...5 {
            stores.append("Store \(i)")
        }
        current = stores[0]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = category!
        self.automaticallyAdjustsScrollViewInsets = false
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel() {
        delegate?.categoryPreferenceViewControllerCancel(self)
    }
    
    @IBAction func save() {
        delegate?.categoryPreferenceViewControllerSave(self)
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

extension CategoryPreferenceViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section != 0 {
            current = stores[indexPath.row]
            storeTable.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cellIdentifier = "HeaderViewCell"
        let cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        if section == 0 {
            cell.textLabel!.text = "Current Selection"
        } else {
            cell.textLabel!.text = "Store Options"
        }
        cell.textLabel!.textColor = UIColor.whiteColor()
        return cell
    }
    
}

extension CategoryPreferenceViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "TableViewCell"
        let cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        if indexPath.section == 0 {
            cell.textLabel!.text = current
        } else {
            cell.textLabel!.text = "\(indexPath.row + 1). \(stores[indexPath.row])"
        }
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return stores.count
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
}

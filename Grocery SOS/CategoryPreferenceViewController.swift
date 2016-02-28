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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = category!
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

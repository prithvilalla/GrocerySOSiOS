//
//  ManagerModifyViewController.swift
//  Grocery SOS
//
//  Created by Prithvi Rajesh Lalla on 3/1/16.
//  Copyright © 2016 Grocery SOS. All rights reserved.
//

import UIKit

protocol ManagerModifyViewControllerDelegate: class {
    func managerModifyViewControllerCancel(controller: ManagerModifyViewController)
    func managerModifyViewControllerSave(controller: ManagerModifyViewController)
}

class ManagerModifyViewController: UIViewController {
    
    weak var delegate: ManagerModifyViewControllerDelegate?
    @IBOutlet weak var textField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        textField.becomeFirstResponder()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel() {
        delegate?.managerModifyViewControllerCancel(self)
    }
    
    @IBAction func save() {
        delegate?.managerModifyViewControllerSave(self)
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

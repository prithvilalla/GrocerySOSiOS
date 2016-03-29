//
//  ChangePasswordViewController.swift
//  Grocery SOS
//
//  Created by Prithvi Rajesh Lalla on 3/28/16.
//  Copyright © 2016 Grocery SOS. All rights reserved.
//

import UIKit

protocol changePasswordViewControllerDelegate: class {
    func changePasswordViewControllerCancel(controller: ChangePasswordViewController)
    func changePasswordViewControllerSave(controller: ChangePasswordViewController)
}

class ChangePasswordViewController: UIViewController {
    
    @IBOutlet weak var currentPassword: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var newPassword2: UITextField!
    
    weak var delegate: changePasswordViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel() {
        delegate?.changePasswordViewControllerCancel(self)
    }
    
    @IBAction func save() {
        delegate?.changePasswordViewControllerSave(self)
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

extension ChangePasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}

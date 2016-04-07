//
//  ProfileViewController.swift
//  Grocery SOS
//
//  Created by Prithvi Rajesh Lalla on 3/28/16.
//  Copyright © 2016 Grocery SOS. All rights reserved.
//

import UIKit

protocol ProfileViewControllerDelegate: class {
    func profileViewControllerCancel(controller: ProfileViewController)
    func profileViewControllerSave(controller: ProfileViewController)
}

class ProfileViewController: UIViewController, changePasswordViewControllerDelegate {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var storeManagerSwitch: UISwitch!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    weak var delegate: ProfileViewControllerDelegate?
    var username: String!
    var password: String!
    var user: User!

    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTextField.text = username
        emailTextField.text = user.email
        phoneTextField.text = user.phone
        storeManagerSwitch.on = user.isManager
        usernameTextField.becomeFirstResponder()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel() {
        delegate?.profileViewControllerCancel(self)
    }
    
    @IBAction func save() {
        delegate?.profileViewControllerSave(self)
    }
    
    @IBAction func changePassword() {
        performSegueWithIdentifier("changePassword", sender: nil)
    }
    
    func changePasswordViewControllerCancel(controller: ChangePasswordViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func changePasswordViewControllerSave(controller: ChangePasswordViewController) {
        dismissViewControllerAnimated(true, completion: nil)
        if password == controller.currentPassword.text && controller.newPassword.text == controller.newPassword2.text && controller.newPassword.text != "" {
            password = controller.newPassword.text!
        } else {
            showPasswordError()
        }
    }
    
    func showPasswordError() {
        let alert = UIAlertController(title: "Error", message: "There seems to be a password issue. Please try again.", preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: false, completion: nil)
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
        if segue.identifier == "changePassword" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! ChangePasswordViewController
            controller.delegate = self
        }
    }

}

extension ProfileViewController: UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let oldText: NSString = textField.text!
        let newText: NSString = oldText.stringByReplacingCharactersInRange(range, withString: string)
        if textField.tag == 1 {
            if newText.length > 0 {
                saveButton.enabled = true
            } else {
                saveButton.enabled = false
            }
        }
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}

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
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var descriptionTextField: UITextField!
    var field: String!
    var data: String!
    var entry: String!
    var category: String!
    var descript: String!
    var addItem: Bool!
    var categories = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = field
        textField.becomeFirstResponder()
        textField.text = data
        textField.placeholder = field
        saveButton.enabled = false
        entry = data
        
        categoryPicker.hidden = !addItem
        descriptionTextField.hidden = !addItem
        
        categories = ["Dairy", "Meat", "Bakery", "Vegetables", "Fruits", "Beverages", "Miscellaneous"]
        categories.sortInPlace()
        category = categories[0]
        
        descript = ""
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

extension ManagerModifyViewController: UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let oldText: NSString = textField.text!
        let newText: NSString = oldText.stringByReplacingCharactersInRange(range, withString: string)
        if textField.tag == 1 {
            if newText.length > 0 && newText != data {
                saveButton.enabled = true
                entry = newText as String
            } else {
                saveButton.enabled = false
            }
        } else {
            descript = newText as String
        }
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}

extension ManagerModifyViewController: UIPickerViewDataSource {
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
}

extension ManagerModifyViewController: UIPickerViewDelegate {
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        category = categories[row]
    }
}

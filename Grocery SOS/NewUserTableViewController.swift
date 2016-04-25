//
//  NewUserTableViewController.swift
//  Grocery SOS
//
//  Created by Prithvi Rajesh Lalla on 4/24/16.
//  Copyright © 2016 Grocery SOS. All rights reserved.
//

import UIKit

protocol NewUserTableViewControllerDelegate: class {
    func newUserTableViewControllerCancel(controller: NewUserTableViewController)
    func newUserTableViewControllerSave(controller: NewUserTableViewController)
}

class NewUserTableViewController: UITableViewController {
    
    var delegate: NewUserTableViewControllerDelegate?
    var loadingViewController: UIAlertController!
    var indicator: UIActivityIndicatorView!
    let serverUrl = "https://grocery-sos.herokuapp.com"
    var token: String?
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password1: UITextField!
    @IBOutlet weak var password2: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var managerSwitch: UISwitch!
    @IBOutlet weak var storeName: UITextField!
    @IBOutlet weak var street: UITextField!
    @IBOutlet weak var city: UITextField!
    @IBOutlet weak var state: UITextField!
    @IBOutlet weak var zip: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        managerSwitch.setOn(false, animated: false)
        username.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel() {
        delegate?.newUserTableViewControllerCancel(self)
    }
    
    @IBAction func save() {
        if !verifyInfo() {
            showError()
        } else {
            userAvailable()
        }
    }
    
    @IBAction func switchToggled() {
        tableView.reloadData()
    }
    
    func verifyInfo() -> Bool {
        if username.text != "" && password1.text == password2.text && password1.text != "" && email.text != "" && phone.text != "" {
            if managerSwitch.on {
                if storeName.text == "" || street.text == "" || city.text == "" || state.text == "" || zip.text == "" {
                    return false
                }
            }
            return true
        }
        return false
    }
    
    func startLoading() {
        loadingViewController = UIAlertController(title: "     ", message: nil, preferredStyle: .Alert)
        indicator = UIActivityIndicatorView(frame: loadingViewController.view.bounds)
        indicator.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        loadingViewController.view.addSubview(indicator)
        indicator.userInteractionEnabled = false
        indicator.color = UIColor.blackColor()
        indicator.startAnimating()
        presentViewController(loadingViewController, animated: false, completion: nil)
    }
    
    func stopLoading() {
        indicator.stopAnimating()
        loadingViewController.dismissViewControllerAnimated(false, completion: nil)
    }
    
    func showError() {
        let alert = UIAlertController(title: "Error", message: "There seems to be an issue with creating the account. Please try again.", preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: false, completion: nil)
    }
    
    func showUsernameError() {
        let alert = UIAlertController(title: "Error", message: "There seems to be a username issue. Please try again or another username.", preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: false, completion: nil)
    }
    
    func parseJSON(data: NSData) -> [String:AnyObject]? {
        do {
            return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String:AnyObject]
        } catch {
            print("parseJSON \(error)")
            return nil
        }
    }
    
    func userAvailable() {
        startLoading()
        let url: NSURL! = NSURL(string: "\(serverUrl)/api/user/available/\(username.text!)")
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error in
            if let error = error {
                self.stopLoading()
                self.showError()
                print("userAvailable Error \(error)")
                return
            } else if let httpResponse = response as? NSHTTPURLResponse where httpResponse.statusCode == 200 {
                if let data = data {
                    let dictionary = self.parseJSON(data)
                    let available = dictionary!["available"] as! Bool
                    dispatch_async(dispatch_get_main_queue()) {
                        if !available {
                            self.stopLoading()
                            self.showUsernameError()
                        } else {
                            self.userCreate()
                        }
                    }
                }
                return
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.stopLoading()
                    self.showError()
                    print("userAvailable Failure \(response)")
                }
                return
            }
        })
        task.resume()
    }
    
    func userCreate() {
        let url: NSURL! = NSURL(string: "\(serverUrl)/api/user/create")
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        let parameters: [String: AnyObject] = ["username":"\(username.text!)", "password":"\(password1.text!)", "email":"\(email.text!)", "phone":"\(phone.text!)", "isManager": managerSwitch.on]
        do {
            try request.HTTPBody = NSJSONSerialization.dataWithJSONObject(parameters, options: [])
        } catch {
            print("Error HTTP POST Body")
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error in
            if let error = error {
                self.stopLoading()
                self.showError()
                print("userCreate Error \(error)")
                return
            } else if let httpResponse = response as? NSHTTPURLResponse where httpResponse.statusCode == 201 {
                if let data = data {
                    let dictionary = self.parseJSON(data)
                    self.token = dictionary!["token"] as? String
                    dispatch_async(dispatch_get_main_queue()) {
                        if self.managerSwitch.on {
                            self.managerAddStore()
                        } else {
                            self.stopLoading()
                            self.delegate?.newUserTableViewControllerSave(self)
                        }
                    }
                }
                return
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.stopLoading()
                    self.showError()
                    print("userCreate Failure \(response)")
                }
                return
            }
        })
        task.resume()
    }
    
    func managerAddStore() {
        let url: NSURL! = NSURL(string: "\(serverUrl)/api/manager/addStore")
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        let address: [String: String] = ["street": "\(street.text!)", "city":"\(city.text!)", "state":"\(state.text!)", "zip":"\(zip.text!)"]
        let storeData: [String: AnyObject] = ["name":"\(storeName.text!)", "address":address, "company":"\(storeName.text!)"]
        let parameters: [String: AnyObject] = ["store": storeData]
        do {
            try request.HTTPBody = NSJSONSerialization.dataWithJSONObject(parameters, options: [])
        } catch {
            print("Error HTTP POST Body")
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("JWT \(token!)", forHTTPHeaderField: "Authorization")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error in
            if let error = error {
                self.stopLoading()
                self.showError()
                print("managerAddStore Error \(error)")
                return
            } else if let httpResponse = response as? NSHTTPURLResponse where httpResponse.statusCode == 201 {
                if let _ = data {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.stopLoading()
                        self.delegate?.newUserTableViewControllerSave(self)
                    }
                }
                return
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.stopLoading()
                    self.showError()
                    print("managerAddStore Failure \(response)")
                }
                return
            }
        })
        task.resume()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if managerSwitch.on {
            return 8
        } else {
            return 5
        }
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }

    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return false
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
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

extension NewUserTableViewController: UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        verifyInfo()
        return true
    }
}
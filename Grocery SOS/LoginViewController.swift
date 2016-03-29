//
//  LoginViewController.swift
//  Grocery SOS
//
//  Created by Prithvi Rajesh Lalla on 3/29/16.
//  Copyright © 2016 Grocery SOS. All rights reserved.
//

import UIKit

protocol LoginViewControllerDelegate: class {
    func loginViewControllerLogin(controller: LoginViewController)
}

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    weak var delegate: LoginViewControllerDelegate?
    var serverUrl: String!
    var username: String?
    var password: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTextField.becomeFirstResponder()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func login() {
        getToken()
    }
    
    func showLoginError() {
        let alert = UIAlertController(title: "Error", message: "There seems to be a username/password issue. Please try again.", preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: false, completion: nil)
    }
    
    func getToken() {
        username = usernameTextField.text!
        password = passwordTextField.text!
        let url: NSURL! = NSURL(string: "\(serverUrl)/api/token/local")
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        let parameters: [String: String] = ["username":"\(username!)", "password":"\(password!)"]
        do {
            try request.HTTPBody = NSJSONSerialization.dataWithJSONObject(parameters, options: [])
        } catch {
            print("Error HTTP POST Body")
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error in
            if let error = error {
                print("getToken Error \(error)")
                return
            } else if let httpResponse = response as? NSHTTPURLResponse where httpResponse.statusCode == 200 {
                if let _ = data {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.delegate?.loginViewControllerLogin(self)
                    }
                }
                return
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.passwordTextField.text = ""
                    self.showLoginError()
                }
                return
            }
        })
        task.resume()
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

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}

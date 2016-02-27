//
//  RoutePreviewViewController.swift
//  Grocery SOS
//
//  Created by Prithvi Rajesh Lalla on 2/27/16.
//  Copyright © 2016 Grocery SOS. All rights reserved.
//

import UIKit

protocol RoutePreviewViewControllerDelegate: class {
    func routerPreviewViewControllerDidCancel(controller: RoutePreviewViewController)
}

class RoutePreviewViewController: UIViewController {
    
    weak var delegate: RoutePreviewViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel() {
        delegate?.routerPreviewViewControllerDidCancel(self)
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

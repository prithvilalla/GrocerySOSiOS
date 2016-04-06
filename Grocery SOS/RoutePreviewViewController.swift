//
//  RoutePreviewViewController.swift
//  Grocery SOS
//
//  Created by Prithvi Rajesh Lalla on 2/27/16.
//  Copyright © 2016 Grocery SOS. All rights reserved.
//

import UIKit
import GoogleMaps

protocol RoutePreviewViewControllerDelegate: class {
    func routePreviewViewControllerDidCancel(controller: RoutePreviewViewController)
}

class RoutePreviewViewController: UIViewController {
    
    weak var delegate: RoutePreviewViewControllerDelegate?
    @IBOutlet weak var routeTable: UITableView!
    @IBOutlet weak var mapView: GMSMapView!
    var stores = [String]()
    var myGPS: CLLocation!
    
    required init?(coder aDecoder: NSCoder) {
        stores.append("Publix")
        stores.append("Ace Hardware")
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        routeTable.editing = true
        self.automaticallyAdjustsScrollViewInsets = false
        
        let latitude = myGPS.coordinate.latitude
        let longitutde = myGPS.coordinate.longitude
        
        let camera = GMSCameraPosition.cameraWithLatitude(latitude, longitude: longitutde, zoom: 10)
        mapView.camera = camera
        mapView.myLocationEnabled = true
        mapView.settings.myLocationButton = true
        
        let publix = GMSMarker()
        publix.position = CLLocationCoordinate2DMake(33.780385, -84.388703)
        publix.title = "Publix"
        publix.map = mapView
        
        let hardware = GMSMarker()
        hardware.position = CLLocationCoordinate2DMake(33.778175, -84.382995)
        hardware.title = "Ace Hardware"
        hardware.map = mapView
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel() {
        delegate?.routePreviewViewControllerDidCancel(self)
    }
    
    @IBAction func navigate() {
        if (UIApplication.sharedApplication().canOpenURL(NSURL(string:"comgooglemaps://")!)) {
            UIApplication.sharedApplication().openURL(NSURL(string:"comgooglemaps://?saddr=Current+Location&daddr=33.780385,-84.388703&directionsmode=driving")!)
        } else {
            print("Can't use comgooglemaps://");
        }
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

extension RoutePreviewViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cellIdentifier = "HeaderViewCell"
        let cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        cell.textLabel!.text = "Store List"
        cell.textLabel!.textColor = UIColor.whiteColor()
        return cell
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .None
    }
    
    func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
}

extension RoutePreviewViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "TableViewCell"
        let cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        cell.textLabel!.text = "\(indexPath.row + 1). \(stores[indexPath.row])"
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stores.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let temp = stores[sourceIndexPath.row]
        stores[sourceIndexPath.row] = stores[destinationIndexPath.row]
        stores[destinationIndexPath.row] = temp
        routeTable.reloadData()
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
}

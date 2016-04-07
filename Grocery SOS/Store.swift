//
//  Store.swift
//  Grocery SOS
//
//  Created by Prithvi Rajesh Lalla on 4/6/16.
//  Copyright © 2016 Grocery SOS. All rights reserved.
//

import UIKit

class Store: NSObject, NSCoding {
    
    var id = Int()
    var name = String()
    var street = String()
    var city = String()
    var state = String()
    var zip = String()
    
    init(id: Int, name: String, street: String, city: String, state: String, zip: String) {
        self.id = id
        self.name = name
        self.street = street
        self.city = city
        self.state = state
        self.zip = zip
    }
    
    required init?(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObjectForKey("id") as! Int
        name = aDecoder.decodeObjectForKey("name") as! String
        street = aDecoder.decodeObjectForKey("street") as! String
        city = aDecoder.decodeObjectForKey("city") as! String
        state = aDecoder.decodeObjectForKey("state") as! String
        zip = aDecoder.decodeObjectForKey("zip") as! String
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(id, forKey: "id")
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(street, forKey: "street")
        aCoder.encodeObject(city, forKey: "city")
        aCoder.encodeObject(state, forKey: "state")
        aCoder.encodeObject(zip, forKey: "zip")
    }
    
}
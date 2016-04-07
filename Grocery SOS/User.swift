//
//  User.swift
//  Grocery SOS
//
//  Created by Prithvi Rajesh Lalla on 4/6/16.
//  Copyright © 2016 Grocery SOS. All rights reserved.
//

import UIKit

class User: NSObject, NSCoding {
    
    var username = String()
    var email = String()
    var phone = String()
    var isManager = Bool()
    
    init(username: String, email: String, phone: String, isManager: Bool) {
        self.username = username
        self.email = email
        self.phone = phone
        self.isManager = isManager
    }
    
    required init?(coder aDecoder: NSCoder) {
        username = aDecoder.decodeObjectForKey("username") as! String
        email = aDecoder.decodeObjectForKey("email") as! String
        phone = aDecoder.decodeObjectForKey("phone") as! String
        isManager = aDecoder.decodeObjectForKey("isManager") as! Bool
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(username, forKey: "username")
        aCoder.encodeObject(email, forKey: "email")
        aCoder.encodeObject(phone, forKey: "phone")
        aCoder.encodeObject(isManager, forKey: "isManager")
    }
    
}
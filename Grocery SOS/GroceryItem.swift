//
//  GroceryItem.swift
//  Grocery SOS
//
//  Created by Prithvi Rajesh Lalla on 2/24/16.
//  Copyright © 2016 Grocery SOS. All rights reserved.
//

import UIKit

class GroceryItem: NSObject, NSCoding {
    
    var name: String = ""
    var checkmark: Bool = false
    var category: String = ""
    var descript: String = ""
    var id = Int()
    
    init(name: String, checkmark: Bool = false, category: String = "Miscellaneous", descript: String = "", id: Int) {
        self.name = name
        self.checkmark = checkmark
        self.category = category
        self.descript = descript
        self.id = id
    }
    
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObjectForKey("name") as! String
        checkmark = aDecoder.decodeObjectForKey("checkmark") as! Bool
        category = aDecoder.decodeObjectForKey("category") as! String
        descript = aDecoder.decodeObjectForKey("descript") as! String
        id = aDecoder.decodeObjectForKey("id") as! Int
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(checkmark, forKey: "checkmark")
        aCoder.encodeObject(category, forKey: "category")
        aCoder.encodeObject(descript, forKey: "descript")
        aCoder.encodeObject(id, forKey: "id")
    }
    
}

func == (lhs: GroceryItem, rhs: GroceryItem ) -> Bool {
    return lhs.name == rhs.name
}
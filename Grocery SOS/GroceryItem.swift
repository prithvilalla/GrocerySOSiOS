//
//  GroceryItem.swift
//  Grocery SOS
//
//  Created by Prithvi Rajesh Lalla on 2/24/16.
//  Copyright © 2016 Grocery SOS. All rights reserved.
//

import UIKit

class GroceryItem: NSObject {
    
    var name: String = ""
    var checkmark: Bool = false
    var category: String = ""
    
    init(name: String, checkmark: Bool = false, category: String = "Miscellaneous") {
        self.name = name
        self.checkmark = checkmark
        self.category = category
    }
    
    func equalTo(target: GroceryItem) -> Bool {
        return self.name == target.name
    }
}
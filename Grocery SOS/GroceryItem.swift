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
    
    init(name: String, checkmark: Bool = false) {
        self.name = name
        self.checkmark = checkmark
    }
    
    func equalTo(target: GroceryItem) -> Bool {
        return self.name == target.name
    }
}
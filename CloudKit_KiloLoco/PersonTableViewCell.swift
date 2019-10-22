//
//  PersonTableViewCell.swift
//  CloudKit_KiloLoco
//
//  Created by Lucas Costa  on 08/10/19.
//  Copyright © 2019 LucasCosta. All rights reserved.
//

import UIKit
import CloudKit

class PersonTableViewCell: UITableViewCell {

    @IBOutlet private weak var name : UILabel!
    @IBOutlet private weak var age : UILabel!
    @IBOutlet private weak var height : UILabel!
    
    var person : CKRecord? {
        
        didSet {
        
            guard let person = person else {return}
            guard let age = person.value(forKey: "age") as? Int else {return}
            guard let height = person.value(forKey: "height") as? Float else {return}

            self.name.text = person.value(forKey: "name") as? String
            self.age.text = String(age)
            self.height.text = String(height)
        }
    }

}

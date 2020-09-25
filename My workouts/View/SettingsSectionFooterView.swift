//
//  SettingsSectionFooterView.swift
//  My workouts
//
//  Created by  Vladyslav Fil on 23.09.2020.
//  Copyright © 2020  Vladyslav Fil. All rights reserved.
//

import UIKit

class SettingsSectionFooterView: UITableViewHeaderFooterView {

    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    static var reuseIdentifier: String {
        return String(describing: self)
    }
    static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: nil)
    }

}

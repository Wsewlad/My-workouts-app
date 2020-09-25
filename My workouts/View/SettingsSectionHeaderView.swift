//
//  SettingsSectionHeaderView.swift
//  My workouts
//
//  Created by  Vladyslav Fil on 11.09.2020.
//  Copyright © 2020  Vladyslav Fil. All rights reserved.
//

import UIKit

class SettingsSectionHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var customContentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    static var reuseIdentifier: String {
        return String(describing: self)
    }
    static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: nil)
    }
    
}

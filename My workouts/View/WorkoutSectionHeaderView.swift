//
//  WorkoutSectionHeaderView.swift
//  My workouts
//
//  Created by  Vladyslav Fil on 28.08.2020.
//  Copyright © 2020  Vladyslav Fil. All rights reserved.
//

import UIKit

class WorkoutSectionHeaderView: UITableViewHeaderFooterView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
    static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: nil)
    }
    
    @IBOutlet weak var customContentView: UIView!
    @IBOutlet weak var exerciseLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
}

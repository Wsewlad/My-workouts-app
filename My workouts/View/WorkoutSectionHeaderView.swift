//
//  WorkoutSectionHeaderView.swift
//  My workouts
//
//  Created by  Vladyslav Fil on 28.08.2020.
//  Copyright © 2020  Vladyslav Fil. All rights reserved.
//

import UIKit

class WorkoutSectionHeaderView: UITableViewHeaderFooterView {
    static let reuseIdentifier: String = String(describing: self)
    static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        customContentView.layer.cornerRadius = 10
        customContentView.layer.masksToBounds = true
    }
    
    @IBOutlet weak var customContentView: UIView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var toggleButton: UIButton!
    
}

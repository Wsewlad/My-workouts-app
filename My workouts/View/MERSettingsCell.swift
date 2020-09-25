//
//  MERSettingsCell.swift
//  My workouts
//
//  Created by  Vladyslav Fil on 10.09.2020.
//  Copyright © 2020  Vladyslav Fil. All rights reserved.
//

import UIKit

class MERSettingsCell: UITableViewCell {

    @IBOutlet weak var exerciseNameLabel: UILabel!
    @IBOutlet weak var maxRepetitionLabel: UILabel!
    @IBOutlet weak var maxRepetitionStepper: UIStepper!
    
    static var reuseIdentifier: String {
        return String(describing: self)
    }
    static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: nil)
    }
    
    var exerciseName: String? {
        didSet {
            if let name = exerciseName {
                exerciseNameLabel.text = name
            }
        }
    }
    
    var maxRepetition: Int32? {
        didSet {
            if let r = maxRepetition {
                maxRepetitionLabel.text = String(format: "%4d", r)
                maxRepetitionStepper.value = Double(r)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}

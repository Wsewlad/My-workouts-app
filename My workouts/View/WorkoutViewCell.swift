//
//  WorkoutViewCell.swift
//  My workouts
//
//  Created by  Vladyslav Fil on 28.08.2020.
//  Copyright © 2020  Vladyslav Fil. All rights reserved.
//

import UIKit

class WorkoutViewCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var iterationLabel: UILabel!
    @IBOutlet weak var repetitionLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    static var reuseIdentifier: String {
        return String(describing: self)
    }
    static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: nil)
    }
    
    var workoutIdx: Int?
    var workout: Workout? {
        didSet {
            if let w = workout {
                repetitionLabel.text = String(format: "%4d", w.repetition)
                timeLabel.text = w.date!.getFormatedDateString(format: "HH:mm a")
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mainView.layer.cornerRadius = 10
        mainView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

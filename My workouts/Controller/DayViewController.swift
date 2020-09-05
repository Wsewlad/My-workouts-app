//
//  DayViewController.swift
//  My workouts
//
//  Created by  Vladyslav Fil on 25.08.2020.
//  Copyright © 2020  Vladyslav Fil. All rights reserved.
//

import UIKit

class DayViewController: UIViewController {

    @IBOutlet weak var dayDetailsTableView: UITableView!
    
    var dataModel = WorkoutsManager()
    var workoutDayManager = WorkoutDayManager()
    
    var day: Day? {
        didSet {
            title = day!.date!.getFormatedDateString()
            workoutDayManager.day = day
            workoutDayManager.loadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dayDetailsTableView.register(WorkoutViewCell.nib, forCellReuseIdentifier: WorkoutViewCell.reuseIdentifier)
        self.dayDetailsTableView.register(WorkoutSectionHeaderView.nib, forHeaderFooterViewReuseIdentifier: WorkoutSectionHeaderView.reuseIdentifier)
        self.dayDetailsTableView.sectionHeaderHeight = 50
        self.dayDetailsTableView.tableFooterView = UIView()
    }
}

//MARK: - TableView Delegate and DataSource methods

extension DayViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return workoutDayManager.exercises.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let workoutsWithCurrentType = workoutDayManager.getWorkoutsBy(exercise: workoutDayManager.exercises[section])
        return workoutsWithCurrentType.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WorkoutViewCell.reuseIdentifier, for: indexPath)
        let workoutsWithCurrentType = workoutDayManager.getWorkoutsBy(exercise: workoutDayManager.exercises[indexPath.section])
        let workoutDate = workoutsWithCurrentType[indexPath.row].date
        let workoutRepetition = workoutsWithCurrentType[indexPath.row].repetition
        let workoutIteration = workoutsWithCurrentType.count - indexPath.row
        
        if let wCell = cell as? WorkoutViewCell {
            wCell.iterationLabel.text = String(format: "%3d", workoutIteration)
            wCell.repetitionLabel.text = String(format: "%4d", workoutRepetition)
            wCell.timeLabel.text = workoutDate!.getFormatedDateString(format: "HH:mm a")
            return wCell
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
    
    //MARK: - Section Header
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: WorkoutSectionHeaderView.reuseIdentifier) as! WorkoutSectionHeaderView
        
        let exercise = workoutDayManager.exercises[section]
        let workouts = workoutDayManager.getWorkoutsBy(exercise: exercise)
        var total = 0
        workouts.forEach { total += Int($0.repetition) }
        
        view.exerciseLabel.text = exercise.name
        view.totalLabel.text = String(format: "%4d", total)
        return view
    }
}

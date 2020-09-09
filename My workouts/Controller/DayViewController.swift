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
    var mainViewController: MainViewController?
    
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
        self.dayDetailsTableView.tableHeaderView = UIView()
        self.dayDetailsTableView.sectionHeaderHeight = 50
        self.dayDetailsTableView.tableFooterView = UIView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        mainViewController?.calendar.reloadData()
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
        let workout = workoutsWithCurrentType[indexPath.row]
        let workoutDate = workout.date
        let workoutRepetition = workout.repetition
        let workoutIteration = workoutsWithCurrentType.count - indexPath.row
        
        if let wCell = cell as? WorkoutViewCell {
            wCell.workoutIdx = workoutDayManager.workouts.firstIndex(of: workout)
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
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let cell = tableView.cellForRow(at: indexPath) as! WorkoutViewCell
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, handler) in
            self.workoutDayManager.deleteWorkout(with: cell.workoutIdx!)
            self.dayDetailsTableView.reloadData()
        }
        deleteAction.backgroundColor = .systemGray
        
        let updateAction = UIContextualAction(style: .normal, title: "Update") { (action, view, handler) in
            print("Update")
        }
        updateAction.backgroundColor = .systemGray2
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, updateAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
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

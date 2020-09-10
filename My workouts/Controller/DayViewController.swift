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
    
    var workoutDayManager = WorkoutDayManager()
    var mainViewController: MainViewController?
    var repetitionPicker: UIPickerView?
    
    var day: Day? {
        didSet {
            title = day!.date!.getFormatedDateString()
            workoutDayManager.day = day
            workoutDayManager.loadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        workoutDayManager.delegete = self
        self.dayDetailsTableView.register(WorkoutViewCell.nib, forCellReuseIdentifier: WorkoutViewCell.reuseIdentifier)
        self.dayDetailsTableView.register(WorkoutSectionHeaderView.nib, forHeaderFooterViewReuseIdentifier: WorkoutSectionHeaderView.reuseIdentifier)
        
        self.dayDetailsTableView.tableHeaderView = createTableHeaderView()
        self.dayDetailsTableView.sectionHeaderHeight = 50
        self.dayDetailsTableView.tableFooterView = UIView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        mainViewController?.calendar.reloadData()
        mainViewController?.updateTotal()
    }
}

//MARK: - WorkoutDayManager Delegate methods

extension DayViewController: WorkoutDayManagerDelegate {
    func backToMainVC() {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - TableView Delegate and DataSource methods

extension DayViewController: UITableViewDelegate, UITableViewDataSource {
    func createTableHeaderView() -> UIView {
        let headerView = UIView()
        headerView.frame.size.height = 70
        let label = UILabel()
        label.text = day!.date!.getFormatedDateString(format: "EEEE, MMM d, yyyy")
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        headerView.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 15.0),
            label.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -15.0),
            label.topAnchor.constraint(equalTo: headerView.topAnchor),
            label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor)
        ])
        return headerView
    }
    
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
        let workoutIteration = workoutsWithCurrentType.count - indexPath.row
        
        if let wCell = cell as? WorkoutViewCell {
            wCell.iterationLabel.text = String(format: "%3d", workoutIteration)
            wCell.workout = workout
            return wCell
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
    
    //MARK: - Add Swipe Actions
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let cell = tableView.cellForRow(at: indexPath) as! WorkoutViewCell
        
        let deleteAction = createDeleteWorkoutAction(workout: cell.workout!)
        let updateAction = createUpdateWorkoutAction(workout: cell.workout!)
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, updateAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    //MARK: - Create Swipe Actions
    
    func createDeleteWorkoutAction(workout: Workout) -> UIContextualAction {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, handler) in
            self.workoutDayManager.delete(workout: workout)
            self.dayDetailsTableView.reloadData()
        }
        deleteAction.backgroundColor = .systemGray
        return deleteAction
    }
    
    func createUpdateWorkoutAction(workout: Workout) -> UIContextualAction {
        let updateAction = UIContextualAction(style: .normal, title: "Update") { (action, view, handler) in
            let updateView = self.createUpdateView(workout: workout)
            
            let alert = UIAlertController(title: "Update", message: "", preferredStyle: .alert)
            alert.setValue(updateView, forKey: "contentViewController")
            
            let action = UIAlertAction(title: "Ok", style: .default) { (action) in
                let selectedRepetition = self.repetitionPicker!.selectedRow(inComponent: 0) + 1
                workout.repetition = Int32(selectedRepetition)
                self.workoutDayManager.saveData()
                self.dayDetailsTableView.reloadData()
            }
            action.setValue(UIColor.label, forKey: "titleTextColor")
            alert.addAction(action)
            
            self.present(alert, animated: true, completion: {
                alert.view.superview?.isUserInteractionEnabled = true
                alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissOnTapOutside)))
            })
        }
        updateAction.backgroundColor = .systemGray2
        return updateAction
    }
    
    @objc func dismissOnTapOutside(){
       self.dismiss(animated: true, completion: nil)
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

//MARK: - UIPickerView Delegate and DataSource methods

extension DayViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func createUpdateView(workout: Workout) -> UIViewController {
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 250, height: 150)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 250, height: 50))
        label.text = "\(workout.exercise!.name!) at \(workout.date!.getFormatedDateString(format: "HH:mm a"))"
        label.textAlignment = .center
        vc.view.addSubview(label)
        
        let prevRepetition = Int(workout.repetition)
        self.repetitionPicker = UIPickerView(frame: CGRect(x: 0, y: 50, width: 250, height: 100))
        self.repetitionPicker?.dataSource = self
        self.repetitionPicker?.delegate = self
        self.repetitionPicker?.selectRow(prevRepetition - 1, inComponent: 0, animated: true)
        vc.view.addSubview(self.repetitionPicker!)
        return vc
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return workoutDayManager.maxRepetitionNumber
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(row + 1)
    }
}

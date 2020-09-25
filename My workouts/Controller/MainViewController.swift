//
//  MainViewController.swift
//  My workouts
//
//  Created by  Vladyslav Fil on 21.08.2020.
//  Copyright © 2020  Vladyslav Fil. All rights reserved.
//

import UIKit
import CoreData
import FSCalendar

class MainViewController: UIViewController {
    
    @IBOutlet weak var exercisePicker: UIPickerView!
    @IBOutlet weak var repetitionPicker: UIPickerView!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var totalWorkoutDaysLabel: UILabel!
    
    var workoutsManager = WorkoutsManager()
    var datePicker: UIDatePicker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        calendar.placeholderType = .fillHeadTail
        loadData()
    }
    
    func saveData() {
        workoutsManager.saveData()
        calendar.reloadData()
    }
    
    func loadData() {
        workoutsManager.loadData()
        calendar.reloadData()
        updateTotal()
        calendar.setCurrentPage(Date(), animated: true)
        let selectedExerciseIdx = self.exercisePicker.selectedRow(inComponent: 0)
        setLastMaxRepetition(exerciseNameIdx: selectedExerciseIdx)
    }
    
    func updateTotal() {
        let workoutDaysInMonth = workoutsManager.getDaysBy(month: calendar.currentPage.month)
        totalWorkoutDaysLabel.text = "Workout days: \(workoutDaysInMonth.count)"
    }
    
    @IBAction func settingsButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: K.settingsSegueIdentifier, sender: self)
    }
}

//MARK: - Picker View Delegate and DataSource Methods

extension MainViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    //MARK: - Add New Workouts
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        let selectedExerciseRowIndex = self.exercisePicker!.selectedRow(inComponent: 0)
        let repetition = self.repetitionPicker!.selectedRow(inComponent: 0) + 1
        
        let confirmView = createConfirmView(selectedExerciseRowIndex, repetition)
        
        let alert = UIAlertController(title: "Add", message: "", preferredStyle: .alert)
        alert.setValue(confirmView, forKey: "contentViewController")
        
        let cancelAction = UIAlertAction(title: "No", style: .default, handler: nil)
        cancelAction.setValue(UIColor.label, forKey: "titleTextColor")
        alert.addAction(cancelAction)
        let saveWorkoutAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            self.workoutsManager.newWorkout(exerciseNameIdx: selectedExerciseRowIndex, repetition: repetition, date: self.datePicker!.date)
            self.loadData()
        }
        saveWorkoutAction.setValue(UIColor.label, forKey: "titleTextColor")
        alert.addAction(saveWorkoutAction)
        
        self.present(alert, animated: true, completion: {
            alert.view.superview?.isUserInteractionEnabled = true
            alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissOnTapOutside)))
        })
    }
    
    @objc func dismissOnTapOutside(){
       self.dismiss(animated: true, completion: nil)
    }
    
    func createConfirmView(_ selectedExerciseRowIndex: Int, _ repetition: Int) -> UIViewController {
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 250, height: 150)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 250, height: 30))
        label.text = "\(repetition) \(workoutsManager.exerciseNames[selectedExerciseRowIndex]) at:"
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 20.0)
        label.textColor = .label
        label.adjustsFontSizeToFitWidth = true
        vc.view.addSubview(label)
        
        self.datePicker = UIDatePicker(frame: CGRect(x: 0, y: 50, width: 250, height: 100))
        self.datePicker?.datePickerMode = .date
        vc.view.addSubview(self.datePicker!)
        return vc
    }
    
    func setLastMaxRepetition(exerciseNameIdx: Int) {
        if let maxExerciseRepetition = workoutsManager.getMaxExerciseRepetition(by: exerciseNameIdx) {
            repetitionPicker?.selectRow(Int(maxExerciseRepetition - 1), inComponent: 0, animated: true)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 {
            setLastMaxRepetition(exerciseNameIdx: row)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerView.tag == 1 ? workoutsManager.exerciseNames.count : workoutsManager.maxRepetitionNumber
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerView.tag == 1 ? workoutsManager.exerciseNames[row] : String(row + 1)
    }
}

//MARK: - FSCalendar DataSource and Delegate

class FSCellTapGestureRecognizer: UITapGestureRecognizer {
    var date: Date?
}

extension MainViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        updateTotal()
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        if workoutsManager.getDayBy(date: date) != nil {
            return UIColor.lightGray
        }
        return nil
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        if workoutsManager.getDayBy(date: date) != nil {
            return UIColor.white
        }
        return nil
    }
    
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at monthPosition: FSCalendarMonthPosition) {
        let tap = FSCellTapGestureRecognizer(target: self, action: #selector(self.openDayDetails))
        tap.date = date
        
        if !cell.isPlaceholder && workoutsManager.getDayBy(date: date) != nil {
            cell.isUserInteractionEnabled = true
            cell.addGestureRecognizer(tap)
        } else {
            cell.gestureRecognizers?.removeAll()
        }
    }
    
    @objc func openDayDetails(sender: FSCellTapGestureRecognizer) {
        performSegue(withIdentifier: K.dayDetailSegueIdentifier, sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tapGesture = sender as? FSCellTapGestureRecognizer {
            let destinationVC = segue.destination as! DayViewController
            destinationVC.day = workoutsManager.getDayBy(date: tapGesture.date!)!
            destinationVC.mainViewController = self
        } else if segue.identifier == K.settingsSegueIdentifier {
            let destinationVC = segue.destination as! SettingsTableViewController
            destinationVC.mainViewController = self
        }
    }
}

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        calendar.placeholderType = .fillHeadTail
        loadData()
    }
    
    //MARK: - CoreData Methods
    func saveData() {
        workoutsManager.saveData()
        calendar.reloadData()
    }
    
    func loadData() {
        workoutsManager.loadData()
        calendar.reloadData()
        updateTotal()
        calendar.setCurrentPage(Date(), animated: true)
    }
    
    func updateTotal() {
        let workoutDaysInMonth = workoutsManager.getDaysBy(month: calendar.currentPage.month)
        totalWorkoutDaysLabel.text = "Workout days: \(workoutDaysInMonth.count)"
    }
}


//MARK: - Picker View Delegate and DataSource Methods

extension MainViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    //MARK: - Add New Workouts
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        let addWorkoutView = createAddWorkoutView()
        
        let alert = UIAlertController(title: "Workout", message: "", preferredStyle: .alert)
        
        alert.setValue(addWorkoutView, forKey: "contentViewController")
        let saveWorkoutAction = UIAlertAction(title: "Save", style: .default) { (action) in
            let selectedExerciseRowIndex = self.exercisePicker!.selectedRow(inComponent: 0)
            let repetition = self.repetitionPicker!.selectedRow(inComponent: 0) + 1
            
            self.workoutsManager.newWorkout(exerciseNameIdx: selectedExerciseRowIndex, repetition: repetition)
            self.loadData()
        }
        alert.addAction(saveWorkoutAction)
        self.present(alert, animated: true, completion: {
            alert.view.superview?.isUserInteractionEnabled = true
            alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissOnTapOutside)))
        })
    }
    
    @objc func dismissOnTapOutside(){
       self.dismiss(animated: true, completion: nil)
    }
    
    func createAddWorkoutView() -> UIViewController {
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 250, height: 300)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 250, height: 20))
        label.text = "Exercise:"
        label.textColor = .systemGray
        label.textAlignment = .center
        vc.view.addSubview(label)
        
        exercisePicker = newPickerView(pickerFrame: CGRect(x: 0, y: 30, width: 250, height: 100), tag: 1)
        vc.view.addSubview(exercisePicker!)
        
        let label2 = UILabel(frame: CGRect(x: 0, y: 150, width: 250, height: 20))
        label2.text = "Repetition:"
        label2.textColor = .systemGray
        label2.textAlignment = .center
        vc.view.addSubview(label2)
        
        repetitionPicker = newPickerView(pickerFrame: CGRect(x: 0, y: 180, width: 250, height: 100), tag: 2)
        vc.view.addSubview(repetitionPicker!)
        
        return vc
    }
    
    func newPickerView(pickerFrame: CGRect, tag: Int) -> UIPickerView {
        let newPicker = UIPickerView(frame: pickerFrame)
        newPicker.tag = tag
        newPicker.delegate = self
        newPicker.dataSource = self
        
        return newPicker
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 {
            if workoutsManager.exerciseNames[row] == "PUSH-UPS" {
                repetitionPicker?.selectRow(29, inComponent: 0, animated: true)
            }
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
    
//    func calendar(_ calendar: FSCalendar, imageFor date: Date) -> UIImage? {
//        if workoutsManager.getDayBy(date: date) != nil {
//            return UIImage(systemName: "checkmark")
//        }
//        return nil
//    }
    
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
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        updateTotal()
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
        }
    }
}

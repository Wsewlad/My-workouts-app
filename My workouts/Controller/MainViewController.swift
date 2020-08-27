//
//  MainViewController.swift
//  My workouts
//
//  Created by  Vladyslav Fil on 21.08.2020.
//  Copyright © 2020  Vladyslav Fil. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UIViewController {

    var workoutsManager = WorkoutsManager()
    var typesPicker: UIPickerView?
    var repetitionPicker: UIPickerView?
    
    
    @IBOutlet weak var totalWorkoutDaysLabel: UILabel!
    @IBOutlet weak var workoutDaysTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        loadData()
    }
    
    //MARK: - CoreData Methods
    func saveData() {
        workoutsManager.saveData()
        workoutDaysTableView.reloadData()
    }
    
    func loadData() {
        workoutsManager.loadData()
        workoutDaysTableView.reloadData()
        totalWorkoutDaysLabel.text = "Total workout days: \(workoutsManager.workoutDays.count)"
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
            let selectedTypeRowIndex = self.typesPicker!.selectedRow(inComponent: 0)
            let repetition = self.repetitionPicker!.selectedRow(inComponent: 0) + 1
            
            self.workoutsManager.newWorkout(typeNameIdx: selectedTypeRowIndex, repetition: repetition)
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
        label.text = "Type:"
        vc.view.addSubview(label)
        
        typesPicker = newPickerView(pickerFrame: CGRect(x: 0, y: 30, width: 250, height: 100), tag: 1)
        vc.view.addSubview(typesPicker!)
        
        let label2 = UILabel(frame: CGRect(x: 0, y: 150, width: 250, height: 20))
        label2.text = "Repetition:"
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
            if workoutsManager.typeNames[row] == "PUSH-UPS" {
                repetitionPicker?.selectRow(29, inComponent: 0, animated: true)
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerView.tag == 1 ? workoutsManager.typeNames.count : workoutsManager.maxRepetitionNumber
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerView.tag == 1 ? workoutsManager.typeNames[row] : String(row + 1)
    }
    
    
}

//MARK: - Table View DataSource Methods
extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workoutsManager.workoutDays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.dayCellIdentifier, for: indexPath)
        cell.textLabel?.text = workoutsManager.getFormatedDateString(date: workoutsManager.workoutDays[indexPath.row].date!)
        return cell
    }
}

//MARK: - Table View Delegate Methods
extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.dayDetailSegueIdentifier, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! DayViewController
        destinationVC.day = workoutsManager.workoutDays[workoutDaysTableView.indexPathForSelectedRow!.row]
    }
}


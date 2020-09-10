//
//  SettingsTableViewController.swift
//  My workouts
//
//  Created by  Vladyslav Fil on 10.09.2020.
//  Copyright © 2020  Vladyslav Fil. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet var settingsTableView: UITableView!
    var settingsManager = SettingsManager()
    var repetitionPicker: UIPickerView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        self.settingsTableView.register(MERSettingsCell.nib, forCellReuseIdentifier: MERSettingsCell.reuseIdentifier)
        settingsManager.loadMERData()
        settingsTableView.sectionHeaderHeight = 100
        settingsTableView.tableFooterView = UIView()
        settingsTableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Maximum Exercise Repetition" : "Exercises"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: MERSettingsCell.reuseIdentifier, for: indexPath)
            
            if let merCell = cell as? MERSettingsCell {
                merCell.exerciseName = settingsManager.maxENames[indexPath.row]
                merCell.maxRepetition = settingsManager.maxERDict[merCell.exerciseName!]
                return merCell
            }
        }
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return settingsManager.maxERDict.count
        }
        return 1
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 0 {
            let cell = tableView.cellForRow(at: indexPath) as! MERSettingsCell
            
            let deleteAction = createDeleteMER(exerciseName: cell.exerciseName!)
            let updateAction = createUpdateMER(exerciseName: cell.exerciseName!, maxRepetition: cell.maxRepetition!)
            
            let configuration = UISwipeActionsConfiguration(actions: [deleteAction, updateAction])
            configuration.performsFirstActionWithFullSwipe = false
            return configuration
        }
        return nil
    }
    
    //MARK: - Create Swipe Actions
    
    func createDeleteMER(exerciseName: String) -> UIContextualAction {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, handler) in
            self.settingsManager.deleteMER(by: exerciseName)
            self.settingsTableView.reloadData()
        }
        deleteAction.backgroundColor = .systemGray
        return deleteAction
    }
    
    func createUpdateMER(exerciseName: String, maxRepetition: Int32) -> UIContextualAction {
        let updateAction = UIContextualAction(style: .normal, title: "Update") { (action, view, handler) in
            let updateView = self.createUpdateView(exerciseName: exerciseName, maxRepetition: maxRepetition)
            
            let alert = UIAlertController(title: "Update", message: "", preferredStyle: .alert)
            alert.setValue(updateView, forKey: "contentViewController")
            
            let action = UIAlertAction(title: "Ok", style: .default) { (action) in
                let selectedRepetition = self.repetitionPicker!.selectedRow(inComponent: 0) + 1
                self.settingsManager.addOrUpdateMER(exerciseName: exerciseName, maxRepetition: Int32(selectedRepetition))
                self.settingsTableView.reloadData()
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
}

//MARK: - UIPickerView Delegate and DataSource methods

extension SettingsTableViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func createUpdateView(exerciseName: String, maxRepetition: Int32) -> UIViewController {
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 250, height: 150)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 250, height: 50))
        label.text = exerciseName
        label.textAlignment = .center
        vc.view.addSubview(label)
        
        let prevRepetition = Int(maxRepetition)
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
        return settingsManager.maxRepetitionNumber
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(row + 1)
    }
}

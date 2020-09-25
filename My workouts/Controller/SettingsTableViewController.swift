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
    var exercisePicker: UIPickerView?
    var mainViewController: MainViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = K.Settings.title
        self.settingsTableView.register(MERSettingsCell.nib, forCellReuseIdentifier: MERSettingsCell.reuseIdentifier)
        self.settingsTableView.register(SettingsSectionHeaderView.nib, forHeaderFooterViewReuseIdentifier: SettingsSectionHeaderView.reuseIdentifier)
        self.settingsTableView.register(SettingsSectionFooterView.nib, forHeaderFooterViewReuseIdentifier: SettingsSectionFooterView.reuseIdentifier)
        settingsTableView.sectionHeaderHeight = CGFloat(K.Settings.sectionHeaderHeight)
        settingsTableView.sectionFooterHeight = CGFloat(K.Settings.sectionFooterHeight)
        settingsTableView.tableFooterView = UIView()
        
        settingsManager.loadMERData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        mainViewController?.loadData()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: SettingsSectionHeaderView.reuseIdentifier) as? SettingsSectionHeaderView else { return nil }
        
        if section == K.Settings.merSectionIdx {
            headerView.titleLabel.text = K.Settings.merSectionTitle
        } else if section == K.Settings.exercisesSectionIdx {
            headerView.titleLabel.text = K.Settings.exercisesTitle
        }
        return headerView
    }
    
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: SettingsSectionFooterView.reuseIdentifier) as? SettingsSectionFooterView  else { return nil }
        
        footerView.deleteButton.tintColor = .systemGray
        footerView.addButton.tintColor = .systemGray
        footerView.deleteButton.removeTarget(self, action: #selector(deleteAllMER), for: .touchUpInside)
        footerView.addButton.removeTarget(self, action: #selector(addMER), for: .touchUpInside)
        
        if section == K.Settings.merSectionIdx {
            if tableView.numberOfRows(inSection: section) > 0 {
                footerView.deleteButton.addTarget(self, action: #selector(deleteAllMER), for: .touchUpInside)
                footerView.deleteButton.tintColor = .red
            }
            if settingsManager.unusedENames.count > 0 {
                footerView.addButton.addTarget(self, action: #selector(addMER), for: .touchUpInside)
                footerView.addButton.tintColor = .blue
            }
        } else if section == K.Settings.exercisesSectionIdx {
            
        }
        return footerView
    }
    
    
    @objc func deleteAllMER() {
        let alert = UIAlertController(title: "Delete", message: "all Maximum Exrcise Repetition?", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            self.settingsManager.deleteAllMER()
            self.settingsTableView.reloadData()
        }
        confirmAction.setValue(UIColor.label, forKey: "titleTextColor")
        alert.addAction(confirmAction)
        
        let cancelAction = UIAlertAction(title: "No", style: .default, handler: nil)
        cancelAction.setValue(UIColor.label, forKey: "titleTextColor")
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: {
            alert.view.superview?.isUserInteractionEnabled = true
            alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissOnTapOutside)))
        })
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        if indexPath.section == K.Settings.merSectionIdx {
            cell = tableView.dequeueReusableCell(withIdentifier: MERSettingsCell.reuseIdentifier, for: indexPath)
            if let merCell = cell as? MERSettingsCell {
                merCell.exerciseName = settingsManager.maxENames[indexPath.row]
                merCell.maxRepetition = settingsManager.maxERDict[merCell.exerciseName!]
                merCell.maxRepetitionStepper.tag = indexPath.row
                merCell.maxRepetitionStepper.addTarget(self, action: #selector(maxRepetitionChanged(_:)), for: .valueChanged)
                return merCell
            }
        }
        return cell
    }
    
    
    @objc func maxRepetitionChanged(_ sender: UIStepper) {
        let stepperParentCellIndexPath = IndexPath(row: sender.tag, section: K.Settings.merSectionIdx)
        if let merCell = settingsTableView.cellForRow(at: stepperParentCellIndexPath) as? MERSettingsCell {
            settingsManager.addOrUpdateMER(exerciseName: merCell.exerciseName!, maxRepetition: Int32(sender.value))
            merCell.maxRepetition = Int32(sender.value)
        }
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return K.Settings.numberOfsections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == K.Settings.merSectionIdx {
            return settingsManager.maxENames.count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == K.Settings.merSectionIdx {
            let cell = tableView.cellForRow(at: indexPath) as! MERSettingsCell
            let deleteAction = createDeleteMERAction(exerciseName: cell.exerciseName!)
            let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
            configuration.performsFirstActionWithFullSwipe = false
            return configuration
        }
        return nil
    }
    
    //MARK: - Create Swipe Actions
    
    func createDeleteMERAction(exerciseName: String) -> UIContextualAction {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, handler) in
            self.settingsManager.deleteMER(by: exerciseName)
            self.settingsTableView.reloadData()
        }
        deleteAction.backgroundColor = .systemGray
        return deleteAction
    }
    
    @objc func addMER() {
        let updateView = self.createAddView()
        
        let alert = UIAlertController(title: "Add", message: "", preferredStyle: .alert)
        alert.setValue(updateView, forKey: "contentViewController")
        
        let action = UIAlertAction(title: "Ok", style: .default) { (action) in
            let selectedRepetition = self.repetitionPicker!.selectedRow(inComponent: 0) + 1
            let selectedExercise = self.settingsManager.unusedENames[self.exercisePicker!.selectedRow(inComponent: 0)]
            self.settingsManager.addOrUpdateMER(exerciseName: selectedExercise, maxRepetition: Int32(selectedRepetition))
            self.settingsTableView.reloadData()
        }
        action.setValue(UIColor.label, forKey: "titleTextColor")
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: {
            alert.view.superview?.isUserInteractionEnabled = true
            alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissOnTapOutside)))
        })
    }
    
    @objc func dismissOnTapOutside(){
       self.dismiss(animated: true, completion: nil)
    }
}

//MARK: - UIPickerView Delegate and DataSource methods

extension SettingsTableViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func createAddView() -> UIViewController {
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 250, height: 200)
        
        self.exercisePicker = newPickerView(pickerFrame: CGRect(x: 0, y: 0, width: 250, height: 100), tag: 1)
        vc.view.addSubview(self.exercisePicker!)
        
        repetitionPicker = newPickerView(pickerFrame: CGRect(x: 0, y: 100, width: 250, height: 100), tag: 2)
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
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerView.tag == 1 ? settingsManager.unusedENames.count : settingsManager.maxRepetitionNumber
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerView.tag == 1 ? settingsManager.unusedENames[row] : String(row + 1)
    }
}

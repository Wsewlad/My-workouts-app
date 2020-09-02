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
            title = dataModel.getFormatedDateString(date: day!.date!)
            workoutDayManager.day = day
            workoutDayManager.loadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dayDetailsTableView.register(WorkoutViewCell.nib, forCellReuseIdentifier: WorkoutViewCell.reuseIdentifier)
        self.dayDetailsTableView.register(WorkoutSectionHeaderView.nib, forHeaderFooterViewReuseIdentifier: WorkoutSectionHeaderView.reuseIdentifier)
        self.dayDetailsTableView.sectionHeaderHeight = 100
        self.dayDetailsTableView.backgroundColor = #colorLiteral(red: 0.9215686275, green: 0.9216203094, blue: 0.9214589, alpha: 1)
        self.dayDetailsTableView.separatorStyle = .none
        self.dayDetailsTableView.sectionFooterHeight = 30
    }
}

//MARK: - TableView Delegate and DataSource methods

extension DayViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return workoutDayManager.types.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.workoutDayManager.hiddenSections.contains(section) {
            return 0
        }
        let workoutsWithCurrentType = workoutDayManager.getWorkoutsBy(type: workoutDayManager.types[section])
        return workoutsWithCurrentType.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WorkoutViewCell.reuseIdentifier, for: indexPath)
        let workoutsWithCurrentType = workoutDayManager.getWorkoutsBy(type: workoutDayManager.types[indexPath.section])
        let workoutDate = workoutsWithCurrentType[indexPath.row].date
        let workoutRepetition = workoutsWithCurrentType[indexPath.row].repetition
        let workoutIteration = workoutsWithCurrentType.count - indexPath.row
        
        if let wCell = cell as? WorkoutViewCell {
            wCell.iterationLabel.text = String(format: "%3d", workoutIteration)
            wCell.repetitionLabel.text = String(format: "%4d", workoutRepetition)
            wCell.timeLabel.text = dataModel.getFormatedDateString(date: workoutDate!, format: "HH:mm a")
            return wCell
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
    
    //MARK: - Section Header Constructor
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let workoutType = workoutDayManager.types[section]
        let workouts = workoutDayManager.getWorkoutsBy(type: workoutType)
        var total = 0
        workouts.forEach { total += Int($0.repetition) }

        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: WorkoutSectionHeaderView.reuseIdentifier) as! WorkoutSectionHeaderView

        view.typeLabel.text = workoutType.name
        view.totalLabel.text = String(format: "%4d", total)

        view.toggleButton.tag = section
        view.toggleButton.addTarget(self, action: #selector(self.hideSection(sender:)), for: .touchUpInside)

        return view
    }
    
    @objc private func hideSection(sender: UIButton) {
        let section = sender.tag
        func indexPathsForSection() -> [IndexPath] {
            var indexPaths = [IndexPath]()
            for row in 0 ..< workoutDayManager.getWorkoutsBy(type: workoutDayManager.types[section]).count {
                indexPaths.append(IndexPath(row: row, section: section))
            }
            return indexPaths
        }
        if self.workoutDayManager.hiddenSections.contains(section) {
            self.workoutDayManager.hiddenSections.remove(section)
            self.dayDetailsTableView.insertRows(at: indexPathsForSection(), with: .fade)
            sender.setImage(UIImage(systemName: "chevron.up.circle.fill"), for: .normal)
        } else {
            self.workoutDayManager.hiddenSections.insert(section)
            self.dayDetailsTableView.deleteRows(at: indexPathsForSection(), with: .fade)
            sender.setImage(UIImage(systemName: "chevron.down.circle.fill"), for: .normal)
        }
    }
    
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: WorkoutSectionHeaderView.reuseIdentifier) as! WorkoutSectionHeaderView
//        view.customContentView.topAnchor.constraint(equalTo: view.topAnchor, constant: 2).isActive = true
//        view.customContentView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
//        view.toggleButton.setImage(nil, for: .normal)
//        view.totalLabel.text = nil
//        view.typeLabel.text = nil
//        
//        return view
//    }
    
}

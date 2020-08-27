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
        
    }
    
}

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
        let cell = tableView.dequeueReusableCell(withIdentifier: K.workoutCellIdentifier, for: indexPath)
        let workoutsWithCurrentType = workoutDayManager.getWorkoutsBy(type: workoutDayManager.types[indexPath.section])
        let workoutDate = workoutsWithCurrentType[indexPath.row].date
        let workoutRepetition = workoutsWithCurrentType[indexPath.row].repetition
        cell.textLabel?.text = "\(dataModel.getFormatedDateString(date: workoutDate!, format: "HH:mm:ss")) (\(workoutRepetition))"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let tableWidth = tableView.frame.size.width
        
        let view = UIView()
        view.backgroundColor = .lightGray
        
        let label = UILabel()
        label.text = workoutDayManager.types[section].name
        label.frame = CGRect(x: 10, y: 0, width: tableWidth - 50, height: 50)
        label.numberOfLines = 0
        view.addSubview(label)
        
        let sectionButton = UIButton()
        sectionButton.tintColor = .black
        sectionButton.setImage(UIImage(systemName: "chevron.up"), for: .normal)
        sectionButton.tag = section
        sectionButton.frame = CGRect(x: tableWidth - 50, y: 0, width: 50, height: 50)
        sectionButton.addTarget(self, action: #selector(self.hideSection(sender:)), for: .touchUpInside)
        view.addSubview(sectionButton)
        
        let border = UIView(frame: CGRect(x: 10, y: 0, width: tableWidth - 20, height: 1))
        border.backgroundColor = .gray
        view.addSubview(border)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
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
            sender.setImage(UIImage(systemName: "chevron.up"), for: .normal)
        } else {
            self.workoutDayManager.hiddenSections.insert(section)
            self.dayDetailsTableView.deleteRows(at: indexPathsForSection(), with: .fade)
            sender.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        }
    }
    
}

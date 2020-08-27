//
//  WorkoutDayManager.swift
//  My workouts
//
//  Created by  Vladyslav Fil on 26.08.2020.
//  Copyright © 2020  Vladyslav Fil. All rights reserved.
//

import UIKit
import CoreData

struct WorkoutDayManager {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var day: Day?
    var workouts = [Workout]()
    var types = [WorkoutType]()
    
    var hiddenSections = Set<Int>()
    
    mutating func loadData() {
        do {
            let workoutsRequest: NSFetchRequest<Workout> = Workout.fetchRequest()
            workoutsRequest.predicate = NSPredicate(format: "day == %@", day!)
            workoutsRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            workouts = try context.fetch(workoutsRequest)
            
            let typesRequest: NSFetchRequest<WorkoutType> = WorkoutType.fetchRequest()
            typesRequest.predicate = NSPredicate(format: "ANY workouts IN %@", workouts)
            types = try context.fetch(typesRequest)
            types = types.sorted { getWorkoutsBy(type: $0)[0].date! > getWorkoutsBy(type: $1)[0].date! }
        } catch {
            print("Failed to load workout data, \(error)")
        }
    }
    
    func getWorkoutsBy(type: WorkoutType) -> [Workout] {
            let nsWorkouts = workouts as NSArray
            let predicate = NSPredicate(format: "type == %@", type)
            return nsWorkouts.filtered(using: predicate) as! [Workout]
    }
}

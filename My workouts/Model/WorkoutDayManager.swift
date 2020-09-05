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
    var exercises = [Exercise]()
    
    mutating func loadData() {
        do {
            let workoutsRequest: NSFetchRequest<Workout> = Workout.fetchRequest()
            workoutsRequest.predicate = NSPredicate(format: "day == %@", day!)
            workoutsRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            workouts = try context.fetch(workoutsRequest)
            
            let exercisesRequest: NSFetchRequest<Exercise> = Exercise.fetchRequest()
            exercisesRequest.predicate = NSPredicate(format: "ANY workouts IN %@", workouts)
            exercises = try context.fetch(exercisesRequest)
            exercises = exercises.sorted { getWorkoutsBy(exercise: $0)[0].date! > getWorkoutsBy(exercise: $1)[0].date! }
        } catch {
            print("Failed to load workout data, \(error)")
        }
    }
    
    func getWorkoutsBy(exercise: Exercise) -> [Workout] {
            let nsWorkouts = workouts as NSArray
            let predicate = NSPredicate(format: "exercise == %@", exercise)
            return nsWorkouts.filtered(using: predicate) as! [Workout]
    }
}

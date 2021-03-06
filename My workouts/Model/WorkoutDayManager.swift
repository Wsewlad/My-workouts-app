//
//  WorkoutDayManager.swift
//  My workouts
//
//  Created by  Vladyslav Fil on 26.08.2020.
//  Copyright © 2020  Vladyslav Fil. All rights reserved.
//

import UIKit
import CoreData

protocol WorkoutDayManagerDelegate {
    func backToMainVC()
}

struct WorkoutDayManager {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var day: Day?
    var workouts = [Workout]()
    var exercises = [Exercise]()
    var delegete: WorkoutDayManagerDelegate?
    let maxRepetitionNumber = 100
    
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
    
    func saveData() {
        do {
            try context.save()
        } catch {
            print("Failed saving workout data, \(error)")
        }
    }
    
    mutating func delete(workout: Workout) {
        let exercise = workout.exercise!
        context.delete(workout)
        if let wIdx = workouts.firstIndex(of: workout) {
            workouts.remove(at: wIdx)
        }
        if getWorkoutsBy(exercise: exercise).count == 0 {
            if let exIdx = exercises.firstIndex(of: exercise) {
                exercises.remove(at: exIdx)
            }
        }
        if workouts.count == 0 {
            context.delete(day!)
            delegete?.backToMainVC()
        }
        saveData()
    }
    
    func getWorkoutsBy(exercise: Exercise) -> [Workout] {
            let nsWorkouts = workouts as NSArray
            let predicate = NSPredicate(format: "exercise == %@", exercise)
            return nsWorkouts.filtered(using: predicate) as! [Workout]
    }
}

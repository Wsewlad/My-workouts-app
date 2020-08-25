//
//  DataModel.swift
//  My workouts
//
//  Created by  Vladyslav Fil on 25.08.2020.
//  Copyright © 2020  Vladyslav Fil. All rights reserved.
//

import UIKit
import CoreData

struct DataModel {
    let maxRepetitionNumber = 100
    let typeNames = ["PUSH-UPS", "JUMPING JACK", "WIDE ARM PUSH-UPS", "SQUATS", "SUMO SQUAT"]
    
    var workoutDays = [Day]()
    var workoutTypes = [WorkoutType]()
    var currentDay: Day?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    func newWorkout(typeNameIdx: Int, repetition: Int) {
        let newWorkout = Workout(context: self.context)
        
        newWorkout.date = Date()
        newWorkout.day = currentDay!
        newWorkout.type = getWorkoutTypeBy(name: typeNames[typeNameIdx])
        newWorkout.repetition = Int32(repetition)
        saveData()
    }
    
    func saveData() {
        do {
            try context.save()
        } catch {
            print("Failed saving workout data, \(error)")
        }
    }
    
    mutating func loadData() {
        do {
            let daysRequest: NSFetchRequest<Day> = Day.fetchRequest()
            workoutDays = try context.fetch(daysRequest)
            
            let today = getStartOfDay(date: Date())
            daysRequest.predicate = NSPredicate(format: "date == %@", today as NSDate)
            let days = try context.fetch(daysRequest)
            if days.count >= 1 {
                currentDay = days[0]
            } else {
                currentDay = Day(context: self.context)
                currentDay?.date = getStartOfDay(date: Date())
            }
            
            let typesRequest: NSFetchRequest<WorkoutType> = WorkoutType.fetchRequest()
            workoutTypes = try context.fetch(typesRequest)
        } catch {
            print("Failed to load workout data, \(error)")
        }
    }
    
    func getWorkoutTypeBy(name: String) -> WorkoutType {
        let request: NSFetchRequest<WorkoutType> = WorkoutType.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", name)
        do {
            let types = try context.fetch(request)
            if types.count >= 1 {
                return types[0]
            }
        } catch {
            print("Failed to load workout type, \(error)")
        }
        let type = WorkoutType(context: self.context)
        type.name = name
        return type
    }
    
    func getStartOfDay(date: Date) -> Date {
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        
        return calendar.startOfDay(for: date)
    }
}

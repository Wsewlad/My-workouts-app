//
//  WorkoutsManager.swift
//  My workouts
//
//  Created by  Vladyslav Fil on 25.08.2020.
//  Copyright © 2020  Vladyslav Fil. All rights reserved.
//

import UIKit
import CoreData

struct WorkoutsManager {
    let maxRepetitionNumber = 100
    let exerciseNames = ["PUSH-UPS", "JUMPING JACK", "WIDE ARM PUSH-UPS", "SQUATS", "SUMO SQUAT"]
    
    var workoutDays = [Day]()
    var exercises = [Exercise]()
    var currentDay: Day?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    func newWorkout(exerciseNameIdx: Int, repetition: Int) {
        let newWorkout = Workout(context: self.context)
        
        newWorkout.date = Date()
        newWorkout.day = currentDay!
        newWorkout.exercise = getExerciseBy(name: exerciseNames[exerciseNameIdx])
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
            daysRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            workoutDays = try context.fetch(daysRequest)
            
            let today = Date().startOfDay
            daysRequest.predicate = NSPredicate(format: "date == %@", today as NSDate)
            let days = try context.fetch(daysRequest)
            if days.count >= 1 {
                currentDay = days[0]
            } else {
                currentDay = Day(context: self.context)
                currentDay?.date = today
            }
            
            let exercisesRequest: NSFetchRequest<Exercise> = Exercise.fetchRequest()
            exercises = try context.fetch(exercisesRequest)
        } catch {
            print("Failed to load workout data, \(error)")
        }
    }
    
    func getDaysBy(month: Int) -> [Day] {
        return workoutDays.filter { $0.date?.month == month }
    }
    
    func getExerciseBy(name: String) -> Exercise {
        let request: NSFetchRequest<Exercise> = Exercise.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", name)
        do {
            let exercises = try context.fetch(request)
            if exercises.count >= 1 {
                // Test log
                print("'\(name)' type exists")
                return exercises[0]
            }
        } catch {
            print("Failed to load exercise, \(error)")
        }
        let exercise = Exercise(context: self.context)
        exercise.name = name
        // Test log
        print("'\(name)' exercise created")
        return exercise
    }
    
    func getDayBy(date: Date) -> Day? {
        return workoutDays.first { $0.date == date.startOfDay }
    }
}

extension Date {
    var startOfDay: Date {
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        return calendar.startOfDay(for: self)
    }
    
    var day: Int {
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        return calendar.dateComponents([.day], from: self).day!
    }
    
    var month: Int {
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        return calendar.dateComponents([.month], from: self).month!
    }
    
    var year: Int {
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        return calendar.dateComponents([.year], from: self).year!
    }
    
    func getFormatedDateString(format: String = "dd.MM.yyyy") -> String {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = format
        return dateFormater.string(from: self)
    }
}

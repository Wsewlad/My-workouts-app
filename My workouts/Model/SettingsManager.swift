//
//  SettingsManager.swift
//  My workouts
//
//  Created by  Vladyslav Fil on 10.09.2020.
//  Copyright © 2020  Vladyslav Fil. All rights reserved.
//

import UIKit

struct SettingsManager {
    let maxRepetitionNumber = 100
    let exerciseNames = ["PUSH-UPS", "JUMPING JACK", "WIDE ARM PUSH-UPS", "SQUATS", "SUMO SQUAT"]
    let defaults = UserDefaults.standard
    var maxERDict = [String: Int32]()
    var maxENames = [String]()
    var unusedENames = [String]()
    
    // MER = Maximum Exercise Repetition
    
    mutating func loadMERData() {
        if let merDict = defaults.dictionary(forKey: K.maxExerciseRepetitionDictName) as? [String: Int32] {
            self.maxERDict = merDict
            self.maxENames = merDict.map { $0.key }.sorted()
            self.unusedENames = self.exerciseNames.difference(from: self.maxENames)
        } else {
            self.maxERDict = [String: Int32]()
            self.maxENames = [String]()
            self.unusedENames = [String]()
        }
    }
    
    mutating func addOrUpdateMER(exerciseName: String, maxRepetition: Int32) {
        var maxERDict = defaults.dictionary(forKey: K.maxExerciseRepetitionDictName) as? [String: Int32] ?? [exerciseName : maxRepetition]
        maxERDict[exerciseName] = maxRepetition
        defaults.set(maxERDict, forKey: K.maxExerciseRepetitionDictName)
        loadMERData()
    }
    
    mutating func deleteMER(by exerciseName: String) {
        if let merDict = defaults.dictionary(forKey: K.maxExerciseRepetitionDictName) as? [String: Int32] {
            var newMERDict = merDict
            newMERDict.removeValue(forKey: exerciseName)
            defaults.set(newMERDict, forKey: K.maxExerciseRepetitionDictName)
            loadMERData()
        }
    }
    
    mutating func deleteAllMER() {
        if let _ = defaults.dictionary(forKey: K.maxExerciseRepetitionDictName) as? [String: Int32] {
            defaults.removeObject(forKey: K.maxExerciseRepetitionDictName)
            loadMERData()
        }
    }
}

extension Array where Element: Hashable {
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}

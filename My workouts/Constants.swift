//
//  Constants.swift
//  My workouts
//
//  Created by  Vladyslav Fil on 21.08.2020.
//  Copyright © 2020  Vladyslav Fil. All rights reserved.
//

import Foundation

struct K {
    static let appName = "My workouts"
    static let dayDetailSegueIdentifier = "WorkoutDayDetailSegue"
    static let settingsSegueIdentifier = "SettingsSegue"
    static let maxExerciseRepetitionDictName = "MaxExerciseRepetitionDict"
    struct Settings {
        static let title = "Settings"
        static let merSectionTitle = "Maximum Exercise Repetition"
        static let exercisesTitle = "Exercises"
        static let numberOfsections = 2
        static let merSectionIdx = 0
        static let exercisesSectionIdx = 1
        static let sectionHeaderHeight = 70
        static let sectionFooterHeight = 100
    }
}

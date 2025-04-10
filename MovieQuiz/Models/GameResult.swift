//
//  GameResult.swift
//  MovieQuiz
//
//  Created by Muhammed Nurmukhanov on 07.04.2025.
//

import Foundation

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
    
    func compareRecords(gameResult: GameResult) -> Bool {
        self.correct > gameResult.correct
    }
}

//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Muhammed Nurmukhanov on 07.04.2025.
//

import Foundation

final class StatisticService: StatisticServiceProtocol {
    
    private let storage: UserDefaults = .standard
    
    private enum Keys: String {
        case correctAnswersAllTime = "CorrectAnswersAllTime"
        case totalAnswersAllTime = "TotalAnswersAllTime"
        case gamesCountAllTime = "GamesCountAllTime"
        case gameDateOfBestGame = "GameDateOfBestGame"
        case correctAnswersOfBestGame = "CorrectAnswersOfBestGame"
        case totalAnswersOfBestGame = "TotalAnswersOfBestGame"
        case totalAccuracyAllTime = "TotalAccuracyOfAllTime"
    }
    
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCountAllTime.rawValue)
        }
        set(newValue) {
            storage.set(newValue, forKey: Keys.gamesCountAllTime.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            let correctAnswers = storage.integer(forKey: Keys.correctAnswersOfBestGame.rawValue)
            let totalAnswers = storage.integer(forKey: Keys.totalAnswersOfBestGame.rawValue)
            if let gameDate = storage.object(forKey: Keys.gameDateOfBestGame.rawValue) as? Date {
                let gameResult = GameResult(correct: correctAnswers, total: totalAnswers, date: gameDate)
                return gameResult
            }
            else {
                let gameResult = GameResult(correct: correctAnswers, total: totalAnswers, date: Date())
                return gameResult
            }
        }
        set(newValue) {
            storage.set(newValue.correct, forKey: Keys.correctAnswersOfBestGame.rawValue)
            storage.set(newValue.total, forKey: Keys.totalAnswersOfBestGame.rawValue)
            storage.set(newValue.date, forKey: Keys.gameDateOfBestGame.rawValue)
        }
    }
    
    private var correctAnswers: Int {
        get {
            storage.integer(forKey: Keys.correctAnswersAllTime.rawValue)
        }
        set(newValue) {
            storage.set(newValue, forKey: Keys.correctAnswersAllTime.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        get {
            if gamesCount != 0 {
                return storage.double(forKey: Keys.totalAccuracyAllTime.rawValue)
            }
            else {
                print("No games played!")
                return 0.0
            }
        }
    }
    
    func store(gameResult: GameResult) {
        let currentTotalAnswers = storage.integer(forKey: Keys.totalAnswersAllTime.rawValue)
        let currentCorrectAnswers = storage.integer(forKey: Keys.correctAnswersAllTime.rawValue)
        let currentGamesCount = storage.integer(forKey: Keys.gamesCountAllTime.rawValue)

        let updatedCorrectAnswers = currentCorrectAnswers + gameResult.correct
        let updatedTotalAnswers = currentTotalAnswers + gameResult.total
        let updatedGamesCount = currentGamesCount + 1

        storage.set(updatedCorrectAnswers, forKey: Keys.correctAnswersAllTime.rawValue)
        storage.set(updatedTotalAnswers, forKey: Keys.totalAnswersAllTime.rawValue)
        storage.set(updatedGamesCount, forKey: Keys.gamesCountAllTime.rawValue)

        let updatedAccuracy = Double(updatedCorrectAnswers) / Double(updatedGamesCount * 10) * 100
        storage.set(updatedAccuracy, forKey: Keys.totalAccuracyAllTime.rawValue)

        if gameResult.compareRecords(gameResult: bestGame) {
            bestGame = gameResult
        } else if currentGamesCount == 0 {
            bestGame = gameResult
        }
    }
}

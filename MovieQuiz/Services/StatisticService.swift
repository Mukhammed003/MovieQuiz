//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Muhammed Nurmukhanov on 07.04.2025.
//

import Foundation

final class StatisticService: StatisticServiceProtocol {
    
    private let storage: UserDefaults = .standard
    
    var gamesCount: Int {
        get {
            storage.integer(forKey: Constants.StatisticStorageKeys.gamesCountAllTime.rawValue)
        }
        set(newValue) {
            storage.set(newValue, forKey: Constants.StatisticStorageKeys.gamesCountAllTime.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            let correctAnswers = storage.integer(forKey: Constants.StatisticStorageKeys.correctAnswersOfBestGame.rawValue)
            let totalAnswers = storage.integer(forKey: Constants.StatisticStorageKeys.totalAnswersOfBestGame.rawValue)
            if let gameDate = storage.object(forKey: Constants.StatisticStorageKeys.gameDateOfBestGame.rawValue) as? Date {
                let gameResult = GameResult(correct: correctAnswers, total: totalAnswers, date: gameDate)
                return gameResult
            }
            else {
                let gameResult = GameResult(correct: correctAnswers, total: totalAnswers, date: Date())
                return gameResult
            }
        }
        set(newValue) {
            storage.set(newValue.correct, forKey: Constants.StatisticStorageKeys.correctAnswersOfBestGame.rawValue)
            storage.set(newValue.total, forKey: Constants.StatisticStorageKeys.totalAnswersOfBestGame.rawValue)
            storage.set(newValue.date, forKey: Constants.StatisticStorageKeys.gameDateOfBestGame.rawValue)
        }
    }
    
    private var correctAnswers: Int {
        get {
            storage.integer(forKey: Constants.StatisticStorageKeys.correctAnswersAllTime.rawValue)
        }
        set(newValue) {
            storage.set(newValue, forKey: Constants.StatisticStorageKeys.correctAnswersAllTime.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        get {
            if gamesCount != 0 {
                return storage.double(forKey: Constants.StatisticStorageKeys.totalAccuracyAllTime.rawValue)
            }
            else {
                print("No games played!")
                return 0.0
            }
        }
    }
    
    func store(gameResult: GameResult) {
        let currentTotalAnswers = storage.integer(forKey: Constants.StatisticStorageKeys.totalAnswersAllTime.rawValue)
        let currentCorrectAnswers = storage.integer(forKey: Constants.StatisticStorageKeys.correctAnswersAllTime.rawValue)
        let currentGamesCount = storage.integer(forKey: Constants.StatisticStorageKeys.gamesCountAllTime.rawValue)

        let updatedCorrectAnswers = currentCorrectAnswers + gameResult.correct
        let updatedTotalAnswers = currentTotalAnswers + gameResult.total
        let updatedGamesCount = currentGamesCount + 1

        storage.set(updatedCorrectAnswers, forKey: Constants.StatisticStorageKeys.correctAnswersAllTime.rawValue)
        storage.set(updatedTotalAnswers, forKey: Constants.StatisticStorageKeys.totalAnswersAllTime.rawValue)
        storage.set(updatedGamesCount, forKey: Constants.StatisticStorageKeys.gamesCountAllTime.rawValue)

        let updatedAccuracy = Double(updatedCorrectAnswers) / Double(updatedGamesCount * 10) * 100
        storage.set(updatedAccuracy, forKey: Constants.StatisticStorageKeys.totalAccuracyAllTime.rawValue)

        if gameResult.compareRecords(gameResult: bestGame) {
            bestGame = gameResult
        } else if currentGamesCount == 0 {
            bestGame = gameResult
        }
    }
}

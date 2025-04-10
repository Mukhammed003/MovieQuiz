//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Muhammed Nurmukhanov on 07.04.2025.
//

protocol StatisticServiceProtocol {
    var gamesCount: Int { get }
    var bestGame: GameResult { get }
    var totalAccuracy: Double { get }
    
    func store(gameResult: GameResult)
}

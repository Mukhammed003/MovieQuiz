//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Muhammed Nurmukhanov on 02.04.2025.
//

import Foundation
import UIKit

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer() 
    func didFailToLoadData(with error: Error)
}

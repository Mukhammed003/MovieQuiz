//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Muhammed Nurmukhanov on 04.05.2025.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    private weak var viewController: MovieQuizViewController?
    private let statisticService: StatisticServiceProtocol
    
    private lazy var questionFactory: QuestionFactoryProtocol = {
        return QuestionFactory(
            moviesLoader: MoviesLoader(networkClient: NetworkClient()),
            delegate: self
        )
    }()

    private var currentQuestion: QuizQuestion?
    private var currentQuestionIndex = 0
    private let questionsAmount = 10
    private var correctAnswers = 0

    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        self.statisticService = StatisticService()
        
        viewController.showLoadingIndicator()
        questionFactory.loadData()
    }

    // MARK: - Button Handlers
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }

    func noButtonClicked() {
        didAnswer(isYes: false)
    }

    // MARK: - QuestionFactoryDelegate handlers

    func didReceiveNextQuestion(question: QuizQuestion?) {
        print("Получен следующий вопрос")
        guard let question = question else { return }
        currentQuestion = question

        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
            self?.viewController?.hideLoadingIndicator()
            self?.viewController?.enableButtons()
        }
    }

    func didLoadDataFromServer() {
        print("Данные загружены, скрытие индикатора загрузки...")
        viewController?.hideLoadingIndicator()
        questionFactory.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }

    // MARK: - Internal Logic

    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }

        let isCorrect = (isYes == currentQuestion.correctAnswer)

        if isCorrect {
            correctAnswers += 1
        }

        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.disableButtons()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.proceedToNextQuestionOrResults()
        }
    }

    private func proceedToNextQuestionOrResults() {
        if isLastQuestion() {
            showResults()
        } else {
            currentQuestionIndex += 1
            
            DispatchQueue.main.async { [weak self] in
                self?.viewController?.showLoadingIndicator()
            }
            
            questionFactory.requestNextQuestion()
        }
    }

    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.showLoadingIndicator()
        }
        
        questionFactory.resetQuestions()
        questionFactory.requestNextQuestion()
    }

    private func isLastQuestion() -> Bool {
        return currentQuestionIndex == questionsAmount - 1
    }

    private func showResults() {
        let gameResult = GameResult(correct: correctAnswers, total: questionsAmount, date: Date())
        statisticService.store(gameResult: gameResult)

        let bestGame = statisticService.bestGame
        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let currentGameResultLine = "Ваш результат: \(correctAnswers)/\(questionsAmount)"
        let bestGameInfoLine = "Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))"
        let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"

        let resultMessage = [
            currentGameResultLine,
            totalPlaysCountLine,
            bestGameInfoLine,
            averageAccuracyLine
        ].joined(separator: "\n")

        let viewModel = QuizResultsAlertModel(
            title: "Этот раунд окончен!",
            text: resultMessage,
            buttonText: "Сыграть ещё раз"
        )

        viewController?.show(quiz: viewModel)
    }

    private func convert(model: QuizQuestion) -> QuizStepModel {
        return QuizStepModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
}



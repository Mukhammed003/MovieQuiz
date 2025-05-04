//
//  MovieQuizPresenterTests.swift
//  MovieQuiz
//
//  Created by Muhammed Nurmukhanov on 04.05.2025.
//

import XCTest
@testable import MovieQuiz

final class MockOfMovieQuizViewController: MovieQuizViewControllerProtocol {
    func show(quiz step: MovieQuiz.QuizStepModel) {
        
    }
    
    func show(quiz result: MovieQuiz.QuizResultsAlertModel) {
        
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        
    }
    
    func showLoadingIndicator() {
        
    }
    
    func hideLoadingIndicator() {
        
    }
    
    func showNetworkError(message: String) {
        
    }
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertToViewModel() {
        let mockOfViewController = MockOfMovieQuizViewController()
        let presenter = MovieQuizPresenter(viewController: mockOfViewController)
        
        let data = Data()
        let question = QuizQuestion(image: data, text: "Question text", correctAnswer: true)
        let viewModel = presenter.convert(model: question)
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}

//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Muhammed Nurmukhanov on 26.04.2025.
//

import XCTest
@testable import MovieQuiz

class MovieQuizUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()

        app = XCUIApplication()
        app.launch()

        continueAfterFailure = false
    }
    
    func testYesButton() {
        sleep(3)
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["Yes"].tap()
        
        sleep(3)
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
    }
    
    func testLabelCountOfQuestion() {
        sleep(2)
        app.buttons["Yes"].tap()
        
        sleep(2)
        let label = app.staticTexts["Index"]
        
        let text = label.label
        
        XCTAssertEqual(text, "2/10")
    }
    
    func testNoButton() {
        sleep(3)
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap()
        
        sleep(3)
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
    }
    
    func testAlertOfEndRound() {
        
        for _ in 0..<10 {
            sleep(2)
            app.buttons["No"].tap()
        }
        
        sleep(2)
        let alert = app.alerts["QuizResultsAlert"]
        
        XCTAssertTrue(alert.exists)
        
        //Этот раунд окончен!    Сыграть ещё раз
        let alertTitleText = alert.label
        let alertButtonText = alert.buttons.firstMatch.label
        
        XCTAssertEqual(alertTitleText, "Этот раунд окончен!")
        XCTAssertEqual(alertButtonText, "Сыграть ещё раз")
    }
    
    override func tearDownWithError() throws {
        app?.terminate()
        app = nil
        
        try super.tearDownWithError()
    }
}


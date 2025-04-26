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
        let firstPoster = app.images["Poster"]
        
        app.buttons["Yes"].tap()
        
        let secondPoster = app.images["Poster"]
        
        XCTAssertFalse(firstPoster == secondPoster)
    }
    
    func testExample() {
        XCTAssertTrue(app.buttons.count > 0)
    }
    
    override func tearDownWithError() throws {
        app?.terminate()
        app = nil
        
        try super.tearDownWithError()
    }
}

//
//  MoviesLoaderTests.swift
//  MovieQuiz
//
//  Created by Muhammed Nurmukhanov on 25.04.2025.
//

import XCTest
@testable import MovieQuiz

struct SubNetworkClient: NetworkRouting {
    
    enum TestError: Error {
        case test
    }
    
    let emulateError: Bool
    
    func fetch(url: URL, handler: @escaping (Result<Data, any Error>) -> Void) {
        if emulateError {
            handler(.failure(TestError.test))
        }
        else {
            handler(.success(expectedResponse))
        }
    }
    
    private var expectedResponse: Data {
        """
                {
                   "errorMessage" : "",
                   "items" : [
                      {
                         "crew" : "Dan Trachtenberg (dir.), Amber Midthunder, Dakota Beavers",
                         "fullTitle" : "Prey (2022)",
                         "id" : "tt11866324",
                         "imDbRating" : "7.2",
                         "imDbRatingCount" : "93332",
                         "image" : "https://m.media-amazon.com/images/M/MV5BMDBlMDYxMDktOTUxMS00MjcxLWE2YjQtNjNhMjNmN2Y3ZDA1XkEyXkFqcGdeQXVyMTM1MTE1NDMx._V1_Ratio0.6716_AL_.jpg",
                         "rank" : "1",
                         "rankUpDown" : "+23",
                         "title" : "Prey",
                         "year" : "2022"
                      },
                      {
                         "crew" : "Anthony Russo (dir.), Ryan Gosling, Chris Evans",
                         "fullTitle" : "The Gray Man (2022)",
                         "id" : "tt1649418",
                         "imDbRating" : "6.5",
                         "imDbRatingCount" : "132890",
                         "image" : "https://m.media-amazon.com/images/M/MV5BOWY4MmFiY2QtMzE1YS00NTg1LWIwOTQtYTI4ZGUzNWIxNTVmXkEyXkFqcGdeQXVyODk4OTc3MTY@._V1_Ratio0.6716_AL_.jpg",
                         "rank" : "2",
                         "rankUpDown" : "-1",
                         "title" : "The Gray Man",
                         "year" : "2022"
                      }
                    ]
                  }
                """.data(using: .utf8) ?? Data()
    }
    
}

class MoviesLoaderTests: XCTestCase {
    func testSuccessLoading() throws {
        //Given
        let subNetworkClient = SubNetworkClient(emulateError: false)
        let loader = MoviesLoader(networkClient: subNetworkClient)
        
        
        //When
        let expectation = expectation(description: "Expectation fulfilled")
        
        //Then
        loader.loadMovies {result in
            switch result {
            case.success(let movies):
                XCTAssertEqual(movies.items.count, 2)
                expectation.fulfill()
            case.failure(_):
                XCTFail("Something get wrong")
            }
        }
        
        waitForExpectations(timeout: 1)
}
    
    func testFailureLoading() throws {
        //Given
        let subNetworkClient = SubNetworkClient(emulateError: true)
        let loader = MoviesLoader(networkClient: subNetworkClient)
        
        //When
        let expectation = expectation(description: "Expectation fulfilled")
        
        loader.loadMovies {reult in
            switch reult {
            case .success(_):
                XCTFail("Something get wrong")
            case .failure(_):
                expectation.fulfill()
            }
        }
        
        //Then
        waitForExpectations(timeout: 1)
    }
}


import Foundation


final class QuestionFactory: QuestionFactoryProtocol {
    
    private let constants = Constants()
    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?
    private var movies: [MostPopularMovie] = []
    private var indexesForOneRound: Set<Int> = []
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
        
    func setup(delegate: QuestionFactoryDelegate?) {
            self.delegate = delegate
        }
    
    func resetQuestions() {
        indexesForOneRound.removeAll()
        
        while indexesForOneRound.count < 10 && indexesForOneRound.count < movies.count {
            if let index = (0..<movies.count).randomElement() {
                indexesForOneRound.insert(index)
            }
        }
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
                guard let self = self else { return }
            
                guard let index = self.indexesForOneRound.randomElement() else {
                        print("Все вопросы показаны")
                        return
                    }

                self.indexesForOneRound.remove(index)
                
                guard let movie = self.movies[safe: index] else { return }
                
                var imageData = Data()
               
               do {
                   
                   imageData = try Data(contentsOf: movie.resizedImageURL)
               } catch {
                   print("Failed to load image")
               }
                
                let rating = Float(movie.rating ?? "") ?? 0
                
                let text = "Рейтинг этого фильма больше чем 7?"
                let correctAnswer = rating > 7
                
                let question = QuizQuestion(image: imageData,
                                             text: text,
                                             correctAnswer: correctAnswer)
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.didReceiveNextQuestion(question: question)
                }
            }
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    switch result {
                    case .success(let mostPopularMovies):
                        self.movies = mostPopularMovies.items
                        self.delegate?.didLoadDataFromServer()
                    case .failure(let error):
                        self.delegate?.didFailToLoadData(with: error)
                    }
                }
            }
        }
} 

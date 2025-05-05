
import Foundation


final class QuestionFactory: QuestionFactoryProtocol {
    
    private let constants = Constants()
    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?
    private var movies: [MostPopularMovie] = []
    private var indexesForOneRound: Set<Int> = []
    
    private let operators: [String] = ["больше", "меньше", "равно"]
    private let approximateRatings: [Float] = [7, 8, 9]
    
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
                   DispatchQueue.main.async { [weak self] in
                       guard let self else { return }
                       self.delegate?.didFailToLoadData(with: error)
                   }
               }
                
                let rating = Float(movie.rating ?? "") ?? 0
            
                guard let approxRating = self.approximateRatings.randomElement() else { return }
                guard let examleOperator = self.operators.randomElement() else { return }
    
                var text: String {
                    if examleOperator == "равно" {
                        return "Рейтинг этого фильма \(String(describing: examleOperator)) на \(Int(approxRating))?"
                    }
                    else {
                        return "Рейтинг этого фильма \(String(describing: examleOperator)) чем \(Int(approxRating))?"
                    }
                }
            
               var correctAnswer: Bool {
                   if examleOperator == "больше" {
                       return rating > approxRating
                   }
                   else if examleOperator == "меньше" {
                       return rating < approxRating
                   }
                   else {
                       return rating == approxRating
                   }
               }
                
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
        print("Загрузка данных началась...")
        moviesLoader.loadMovies { [weak self] result in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    switch result {
                    case .success(let mostPopularMovies):
                        print("Данные успешно загружены")
                        self.movies = mostPopularMovies.items
                        self.resetQuestions()
                        self.delegate?.didLoadDataFromServer()
                    case .failure(let error):
                        print("Ошибка загрузки данных: \(error)")
                        self.delegate?.didFailToLoadData(with: error)
                    }
                }
            }
        }
} 

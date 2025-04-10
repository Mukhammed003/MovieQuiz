
import Foundation


final class QuestionFactory: QuestionFactoryProtocol {
    
    private let constants = Constants()
    weak var delegate: QuestionFactoryDelegate?
        
    func setup(delegate: QuestionFactoryDelegate?) {
            self.delegate = delegate
        }
    
    private var indexesOfQuestions: Set<Int> = []
    
    func requestNextQuestion() {
        guard let index = indexesOfQuestions.randomElement() else {
            delegate?.didReceiveNextQuestion(question: nil)
            return
        }

        let question = constants.questions[index]
        delegate?.didReceiveNextQuestion(question: question)
        indexesOfQuestions.remove(index)
    }
    
    func resetQuestions() {
        self.indexesOfQuestions = Set(0..<constants.questions.count)
    }
} 

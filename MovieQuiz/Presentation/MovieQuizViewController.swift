import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    @IBOutlet private weak var imageViewOfMovie: UIImageView!
    @IBOutlet private weak var labelOfCounter: UILabel!
    @IBOutlet private weak var labelOfQuestion: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    private let questionsAmount: Int = 10
    
    private var alertPresenter: AlertPresenter?
    private var questionFactory: QuestionFactoryProtocol = QuestionFactory()
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticServiceProtocol = StatisticService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let questionFactory = QuestionFactory()
        self.questionFactory = questionFactory
        questionFactory.setup(delegate: self)
        questionFactory.resetQuestions()
        questionFactory.requestNextQuestion()
        statisticService = StatisticService()
        alertPresenter = AlertPresenter(viewController: self)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }

        currentQuestion = question
        let viewModel = convertToQuizStepViewModel(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.showQuizStepViewModel(quiz: viewModel)
        }
    }
    
    private func showQuizStepViewModel(quiz step: QuizStepModel) {
      
        imageViewOfMovie.image = step.image
        
        labelOfQuestion.text = step.question
        
        labelOfCounter.text = step.questionNumber
    }

    private func convertToQuizStepViewModel(model: QuizQuestion) -> QuizStepModel {
        
        var quizStep =
        QuizStepModel(
                    image: UIImage(named: model.image) ?? UIImage(),
                    question: model.text,
                    questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        
        return quizStep
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect { // 1
            correctAnswers += 1 // 2
        }
        
        yesButton.isEnabled = false
        noButton.isEnabled = false
        
        imageViewOfMovie.layer.masksToBounds = true
        imageViewOfMovie.layer.borderWidth = 8
        imageViewOfMovie.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.showNextQuestionOrResults()
            
            self.yesButton.isEnabled = true
            self.noButton.isEnabled = true
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            let gameResult = GameResult(correct: correctAnswers, total: questionsAmount, date: Date())
            let date = statisticService.bestGame.date
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy HH:mm"
            let formattedDate = formatter.string(from: date)
            let message = "Ваш результат: \(correctAnswers)/10\n Количество сыгранных квизов: \(statisticService.gamesCount)\n Рекорд: \(statisticService.bestGame.correct)/10 (\(formattedDate))\n Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"

            let alertModel = AlertModel(
                title: "Этот раунд окончен!",
                message: message,
                buttonText: "Сыграть ещё раз",
                completion: { [weak self] in
                    guard let self else { return }
                    self.currentQuestionIndex = 0
                    self.correctAnswers = 0
                    self.statisticService.store(gameResult: gameResult)
                    self.questionFactory.resetQuestions()
                    self.questionFactory.requestNextQuestion()
                    self.imageViewOfMovie.layer.borderColor = UIColor.clear.cgColor
                }
            )

            alertPresenter?.showQuizResultsViewModel(alert: alertModel)

        } else {
            currentQuestionIndex += 1
            questionFactory.requestNextQuestion()
            imageViewOfMovie.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
    // MARK: - Lifecycle
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else { return }
        let isCorrect = !currentQuestion.correctAnswer
            showAnswerResult(isCorrect: isCorrect)
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else { return }
        let isCorrect = currentQuestion.correctAnswer
            showAnswerResult(isCorrect: isCorrect)
    }
}

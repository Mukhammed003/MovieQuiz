import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepModel)
    func show(quiz result: QuizResultsAlertModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
}

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    @IBOutlet private var imageViewOfMovie: UIImageView!
    @IBOutlet private var labelOfQuestion: UILabel!
    @IBOutlet private var labelOfCounter: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    
    private var presenter: MovieQuizPresenter!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageViewOfMovie.layer.cornerRadius = 20
        presenter = MovieQuizPresenter(viewController: self)
        
        print("Something")
    }
    
    // MARK: - Button Actions
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    // MARK: - View Methods
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    func disableButtons() {
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
    
    func enableButtons() {
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    
    func show(quiz step: QuizStepModel) {
        imageViewOfMovie.layer.borderColor = UIColor.clear.cgColor
        imageViewOfMovie.image = step.image
        labelOfQuestion.text = step.question
        labelOfCounter.text = step.questionNumber
    }
    
    func show(quiz result: QuizResultsAlertModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert
        )
        
        alert.view.accessibilityIdentifier = "QuizResultsAlert"
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            self?.presenter.restartGame()
        }
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageViewOfMovie.layer.masksToBounds = true
        imageViewOfMovie.layer.borderWidth = 8
        imageViewOfMovie.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    func showNetworkError(message: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let alert = UIAlertController(
                title: "Ошибка",
                message: message,
                preferredStyle: .alert
            )
            let action = UIAlertAction(title: "Попробовать ещё раз", style: .default) { [weak self] _ in
                self?.presenter.restartGame()
            }
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
}

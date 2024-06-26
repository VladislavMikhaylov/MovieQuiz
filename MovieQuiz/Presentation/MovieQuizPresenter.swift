import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    weak var viewController: MovieQuizViewController?
    private var questionFactory: QuestionFactoryProtocol?
    private var statisticService: StatisticService = StatisticServiceImplementation()
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private var currentQuestion: QuizQuestion?
    private var correctAnswers: Int = 0
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController as? MovieQuizViewController
    }
    
    func loadData() {
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    // MARK: - Buttons
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    // MARK: - Questions
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func requestNextQuestion() {
        viewController?.showLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        
        let givenAnswer = isYes
        let isCorrect = givenAnswer == currentQuestion.correctAnswer
        viewController?.highlightImageBorder(isCorrect: isCorrect)
        showAnswerResult(isCorrect: isCorrect)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.hideLoadingIndicator()
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    // MARK: - Network
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        viewController?.hideLoadingIndicator()
        viewController?.showNetworkError(message: error.localizedDescription)
    }
    
    // MARK: - Results
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        viewController?.changeStateButton(isEnabled: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.viewController?.changeStateButton(isEnabled: true)
            self.showNextQuestionOrResults()
        }
    }
    
    private func showResults() {
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        let currentRecord = "\(statisticService.bestGame.correct)/\(statisticService.bestGame.total)"
        let totalCount = "\(statisticService.gamesCount)"
        let recordTime = statisticService.bestGame.date.dateTimeString
        let accuracy = String(format: "%.2f", statisticService.totalAccuracy)
        
        let text = """
        Ваш результат: \(correctAnswers)/\(questionsAmount)
        Количество сыгранных квизов: \(totalCount)
        Рекорд: \(currentRecord) (\(recordTime))
        Средняя точность: \(accuracy)%
        """
        
        let alertModel = AlertModel(title: "Этот раунд окончен!", message: text, buttonText: "Сыграть ещё раз") { [weak self] in
            self?.restartGame()
        }
        
        let alertPresenter = AlertPresenter()
        alertPresenter.delegate = viewController
        viewController?.alertPresenter = alertPresenter
        alertPresenter.show(quiz: alertModel)
    }
    
    func restartGame() {
        resetQuestionIndex()
        correctAnswers = 0
        requestNextQuestion()
    }
    
    func showNextQuestionOrResults() {
        if isLastQuestion() {
            showResults()
        } else {
            switchToNextQuestion()
            requestNextQuestion()
        }
    }
}

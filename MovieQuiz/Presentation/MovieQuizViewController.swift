import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // Конвертация вопроса для экрана
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(self.currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    // Показ вопроса на экран
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    // Добавления рамки правильного цвета вокруг афишы
    private func showAnswerResult(isCorrect: Bool) {
        yesButton.isEnabled = false
        noButton.isEnabled = false
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        isCorrect ? correctAnswers += 1 : nil
        // запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.imageView.layer.borderWidth = 0
            self.yesButton.isEnabled = true
            self.noButton.isEnabled = true
            self.showNextQuestionOrResults()
        }
    }
    
    // Новый вопрос либо результат квиза
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            let text = correctAnswers == questionsAmount ?
            "Поздравляем, вы ответили на 10 из 10!" :
            "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            questionFactory.requestNextQuestion()
        }
    }
    
    // Показ результата квиза
    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.imageView.layer.borderWidth = 0
            questionFactory.requestNextQuestion()
        }
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // Текущий вопрос
    private var currentQuestionIndex = 0
    // Счетчик правильных ответов
    private var correctAnswers = 0
    
    private let questionsAmount: Int = 10
    private let questionFactory = QuestionFactory()
    private var currentQuestion: QuizQuestion?
    
    // MARK: - Привязка ViewController
    //Афиша
    @IBOutlet private weak var imageView: UIImageView!
    //Счетчик вопроса
    @IBOutlet private weak var counterLabel: UILabel!
    //Текст вопроса
    @IBOutlet private weak var textLabel: UILabel!
    //Нет кнопка
    @IBOutlet private weak var noButton: UIButton!
    //Да кнопка
    @IBOutlet private weak var yesButton: UIButton!
    //Да кнопка действие
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    //Нет кнопка действие
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        questionFactory.delegate = self
        questionFactory.requestNextQuestion()
        
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
}

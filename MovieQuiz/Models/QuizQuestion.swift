import UIKit

// строка с названием фильма совпадает с названием картинки афиши фильма в Assets
struct QuizQuestion {
    let image: String   // строка с вопросом о рейтинге фильма
    let text: String   // булевое значение (true, false), правильный ответ на вопрос
    let correctAnswer: Bool
}

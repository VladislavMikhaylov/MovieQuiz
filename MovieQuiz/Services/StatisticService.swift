import UIKit

final class StatisticService: StatisticServiceProtocol {
    private let storage: UserDefaults = .standard
    
    var totalAccuracy: Double {
        get {
            let total = storage.integer(forKey: Keys.total.rawValue)
            let correct = storage.integer(forKey: Keys.correct.rawValue)
            return Double(100) * Double(correct) / Double(total)
        }
    }
    
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
            let total = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            let date = storage.object(forKey: Keys.date.rawValue) as? Date ?? Date()
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.date.rawValue)
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        gamesCount += 1
        
        // обновляем общее количество правильных вопросов и ответов
        let totalCorrect = storage.integer(forKey: Keys.correct.rawValue) + count
        let totalQuestions = storage.integer(forKey: Keys.total.rawValue) + amount
        storage.set(totalCorrect, forKey: Keys.correct.rawValue)
        storage.set(totalQuestions, forKey: Keys.total.rawValue)
        
        // обновляем лучший результат, если текущий лучше
        let previousBestGame = self.bestGame
        let newResult = GameResult(correct: count, total: amount, date: Date())
        if newResult.isBetterThan(previousBestGame) {
            self.bestGame = newResult
        }
    }
    
    private enum Keys: String {
        case correct
        case total
        case gamesCount
        case date
        case bestGameCorrect
        case bestGameTotal
    }
}

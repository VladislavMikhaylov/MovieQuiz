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
            let correct = storage.integer(forKey: Keys.correct.rawValue)
            let total = storage.integer(forKey: Keys.total.rawValue)
            let date = storage.object(forKey: Keys.date.rawValue)as? Date ?? Date()
            return GameResult (correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.correct.rawValue)
            storage.set(newValue.total, forKey: Keys.total.rawValue)
            storage.set(newValue.date, forKey: Keys.date.rawValue)
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        gamesCount += 1
        
        let previousBestGame = self.bestGame
        let correct = storage.integer(forKey: Keys.correct.rawValue) + count
        let total = storage.integer(forKey: Keys.total.rawValue) + amount
        let newResult = GameResult(correct: count, total: amount, date: Date())
        if newResult.isBetterThan(previousBestGame) {
            self.bestGame = newResult
        }
    }
    
    private enum Keys: String {
        case correct
        case bestGame
        case gamesCount
        case date
        case total
    }
}

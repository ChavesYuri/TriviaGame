import Foundation

public class Player<Question: Hashable, Answer>: Equatable {
    private let id: UUID = UUID()
    public let name: String
    public var score: Int = 0
    public var answers: [Question: Answer] = [:]
    
    public init(name: String) {
        self.name = name
    }
    
    public func incrementScore(value: Int) {
        score += value
    }
    
    public static func == (lhs: Player<Question, Answer>, rhs: Player<Question, Answer>) -> Bool {
        lhs.id == rhs.id
    }
}

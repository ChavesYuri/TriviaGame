import Foundation

public class Player<Question: Hashable, Answer>: Equatable {
    private let id: UUID = UUID()
    public let name: String
    public var score: Int = 0
    public var answers: [Question: (answer: Answer, time: TimeInterval)] = [:]
    
    public init(name: String) {
        self.name = name
    }
    
    public static func == (lhs: Player<Question, Answer>, rhs: Player<Question, Answer>) -> Bool {
        lhs.id == rhs.id
    }
}

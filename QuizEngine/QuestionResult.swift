import Foundation

public struct QuestionResult<Question: Hashable, Answer> {
    public let answer: Answer
    public let question: Question
    public let time: TimeInterval
    public let isCorrect: Bool
    
    public init(answer: Answer, question: Question, time: TimeInterval, isCorrect: Bool) {
        self.answer = answer
        self.question = question
        self.time = time
        self.isCorrect = isCorrect
    }
}

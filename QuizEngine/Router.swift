import Foundation

public protocol Router {
    associatedtype Question: Hashable
    associatedtype Answer
    
    typealias AnswerCallback = (Answer, TimeInterval) -> Void
    func routeToPlayerTurn(player: Player<Question, Answer>, questionNumber: Int, _ onStart: @escaping () -> Void)
    func routeToQuestionScreen(_ question: Question, _ answer: @escaping AnswerCallback)
    func routeToQuestionResult(questionResult: QuestionResult<Question, Answer>, completion: @escaping () -> Void)
    func routeToRoundResult(players: [Player<Question, Answer>], completion: @escaping () -> Void)
    func routeToGameResult()
}

import Foundation

public protocol Router {
    associatedtype Question: Hashable
    associatedtype Answer
    
    typealias AnswerCallback = (Answer) -> Void
    func routeToPlayerTurn(player: Player<Question, Answer>, _ onStart: @escaping () -> Void)
    func routeToQuestionScreen(_ question: Question, _ answer: @escaping AnswerCallback)
    func routeToQuestionResult(completion: @escaping () -> Void)
    func routeToRoundResult(completion: @escaping () -> Void)
    func routeToGameResult()
}

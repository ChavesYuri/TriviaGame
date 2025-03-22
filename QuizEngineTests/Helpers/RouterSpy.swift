import Foundation
import QuizEngine

final class RouterSpy: Router {
    private(set) var playerTurnRequests: [(player: Player<String, String>, questionNumber: Int, onStart: () -> Void)] = []
    
    func routeToPlayerTurn(player: Player<String, String>, questionNumber: Int, _ onStart: @escaping () -> Void) {
        playerTurnRequests.append((player, questionNumber, onStart))
    }
    
    private(set) var questionsRequests: [(question: String, answer: (String, TimeInterval) -> Void)] = []
    
    func routeToQuestionScreen(_ question: String, _ answer: @escaping (String, TimeInterval) -> Void) {
        questionsRequests.append((question, answer))
    }
    
    private(set) var questionResultRequests: [(result: QuestionResult<Question, Answer>, completion: () -> Void)] = []
    
    func routeToQuestionResult(questionResult: QuestionResult<Question, Answer>, completion: @escaping () -> Void) {
        questionResultRequests.append((questionResult, completion))
    }
    
    private(set) var roundResultRequests: [(players: [Player<String, String>], completion: () -> Void)] = []
    
    func routeToRoundResult(players: [Player<String, String>], completion: @escaping () -> Void) {
        roundResultRequests.append((players, completion))
    }
    
    private(set) var gameResultCallCount = 0
    
    func routeToGameResult() {
        gameResultCallCount += 1
    }
}

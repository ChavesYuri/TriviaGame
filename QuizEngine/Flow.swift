import Foundation

public protocol Router {
    typealias Question = String
    typealias Answer = (String) -> Void
    func routeToPlayerTurn(player: Player, _ onStart: @escaping () -> Void)
    func routeToQuestionScreen(_ question: Question, _ answer: @escaping Answer)
    func routeToQuestionResult()
    func routeToGameResult()
}

public struct Player: Equatable {
    let name: String
    var score: Int = 0
    
    public init(name: String) {
        self.name = name
    }
}

public final class Flow {
    private let players: [Player]
    private let router: Router
    private let questions: [String]
    
    
    public init(players: [Player], router: Router, questions: [String]) {
        self.players = players
        self.router = router
        self.questions = questions
    }
    
    public func start() {
        if let firstQuestion = questions.first, let firstPlayer = players.first {
            router.routeToPlayerTurn(player: firstPlayer, { [weak self] in
                self?.routeToQuestion(firstQuestion, player: firstPlayer)
            })
        } else {
            router.routeToGameResult()
        }
    }
    
    private func routeToQuestion(_ question: Router.Question, player: Player) {
        router.routeToQuestionScreen(question, { _ in })
    }
}

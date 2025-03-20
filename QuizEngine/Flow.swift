import Foundation

public protocol Router {
    typealias Question = String
    typealias Answer = (String) -> Void
    func routeToPlayerTurn(player: Player, _ onStart: @escaping () -> Void)
    func routeToQuestionScreen(_ question: Question, _ answer: @escaping Answer)
    func routeToQuestionResult(completion: @escaping () -> Void)
    func routeToRoundResult(completion: @escaping () -> Void)
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
            startGame(with: firstQuestion, player: firstPlayer)
        } else {
            router.routeToGameResult()
        }
    }
    
    private func startGame(with question: Router.Question, player: Player) {
        router.routeToPlayerTurn(player: player, { [weak self] in
            self?.routeToQuestion(question, player: player)
        })
    }
    
    private func routeToQuestion(_ question: Router.Question, player: Player) {
        router.routeToQuestionScreen(question, {
            self.routeToQuestionResult(question: question, player: player, answer: $0)
        })
    }
    
    private func routeToQuestionResult(question: Router.Question, player: Player, answer: String) {
        self.router.routeToQuestionResult {
            self.nextPlayerOrRoundResult(from: question, player: player)
        }
    }
    
    private func nextPlayerOrRoundResult(from question: Router.Question, player: Player) {
        if let playerIndex = players.firstIndex(of: player), (playerIndex + 1) < players.count {
            // If there's more players to answer the same question
            let nextPlayer = players[playerIndex + 1]
            startGame(with: question, player: nextPlayer)
        } else {
            router.routeToRoundResult {
                self.nextQuestionOrGameResult(question: question, player: player)
            }
        }
    }
    
    private func nextQuestionOrGameResult(question: Router.Question, player: Player) {
        if let questionIndex = questions.firstIndex(of: question), (questionIndex + 1) < questions.count, let firstPlayer = players.first {
            // If is the last Player and there's more questions
            let nextQuestion = questions[questionIndex + 1]
            routeToQuestion(nextQuestion, player: firstPlayer)
        }
    }
}

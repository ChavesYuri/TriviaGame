import Foundation

public final class Flow <Question: Hashable, Answer, R: Router> where R.Question == Question, R.Answer == Answer {
    private let winnerScore: Int = 3
    private var players: [Player<Question, Answer>]
    private let router: R
    private let questions: [Question]
    private let scoring: ([Player<Question, Answer>], Question) -> Void
    private let isAnswerCorrect: (Question, Answer) -> Bool
    
    
    public init(
        players: [Player<Question, Answer>],
        router: R,
        questions: [Question],
        scoring: @escaping ([Player<Question, Answer>], Question) -> Void,
        isAnswerCorrect: @escaping (Question, Answer) -> Bool
    ) {
        self.players = players
        self.router = router
        self.questions = questions
        self.scoring = scoring
        self.isAnswerCorrect = isAnswerCorrect
    }
    
    public func start() {
        if let firstQuestion = questions.first, let firstPlayer = players.first {
            routeToPlayerTurn(with: firstQuestion, player: firstPlayer)
        } else {
            router.routeToGameResult()
        }
    }
    
    private func routeToPlayerTurn(with question: Question, player: Player<Question, Answer>) {
        let questionNumber = (questions.firstIndex(of: question) ?? 0) + 1
        router.routeToPlayerTurn(player: player, questionNumber: questionNumber, { [weak self] in
            self?.routeToQuestion(question, player: player)
        })
    }
    
    private func routeToQuestion(_ question: Question, player: Player<Question, Answer>) {
        router.routeToQuestionScreen(question, { [weak self] in
            self?.routeToQuestionResult(question: question, player: player, answer: $0, time: $1)
        })
    }
    
    private func routeToQuestionResult(question: Question, player: Player<Question, Answer>, answer: Answer, time: TimeInterval) {
        if let currentPlayerIndex = players.firstIndex(of: player) {
            players[currentPlayerIndex].answers[question] = (answer, time)
        }
        
        let questionResult = QuestionResult(answer: answer, question: question, time: time, isCorrect: isAnswerCorrect(question, answer))
        router.routeToQuestionResult(questionResult: questionResult) { [weak self] in
            self?.nextPlayerOrRoundResult(from: question, player: player)
        }
    }
    
    private func nextPlayerOrRoundResult(from question: Question, player: Player<Question, Answer>) {
        if let playerIndex = players.firstIndex(of: player), (playerIndex + 1) < players.count {
            /// If there's more players to answer the same question
            let nextPlayer = players[playerIndex + 1]
            routeToPlayerTurn(with: question, player: nextPlayer)
        } else {
            score(for: question)
            router.routeToRoundResult(players: players) { [weak self] in
                self?.nextQuestionOrGameResult(question: question, player: player)
            }
        }
    }
    
    private func nextQuestionOrGameResult(question: Question, player: Player<Question, Answer>) {
        if let _ = winner() {
            router.routeToGameResult()
        } else if let questionIndex = questions.firstIndex(of: question), (questionIndex + 1) < questions.count, let firstPlayer = players.first {
            /// If is the last Player and there's more questions
            let nextQuestion = questions[questionIndex + 1]
            routeToPlayerTurn(with: nextQuestion, player: firstPlayer)
        } else {
            router.routeToGameResult()
        }
    }
    
    private func score(for question: Question) {
        scoring(players, question)
    }
    
    private func winner() -> Player<Question, Answer>? {
        players.first(where: { $0.score == winnerScore })
    }
}

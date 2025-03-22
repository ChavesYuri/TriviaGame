import Foundation

public class Game<Question: Hashable, Answer, R: Router> where R.Question == Question, R.Answer == Answer {
    private let flow: Flow<Question, Answer, R>
    
    public init(flow: Flow<Question, Answer, R>) {
        self.flow = flow
    }
}

public func startGame<Question: Hashable, Answer: Equatable, R: Router>(
    players: [Player<Question, Answer>],
    questions: [Question],
    router: R,
    correctAnswers: [Question: Answer]
) -> Game<Question, Answer, R> where R.Question == Question, R.Answer == Answer {
    let flow = Flow(
        players: players,
        router: router,
        questions: questions,
        scoring: { GamePolicy.scoring(players: $0, question: $1, correctAnswers: correctAnswers) },
        isAnswerCorrect: { GamePolicy.validateQuestion( question: $0, answer: $1, correctAnswers: correctAnswers) })
    flow.start()
    return Game(flow: flow)
}

internal final class GamePolicy {
    internal static func validateQuestion<Question: Hashable, Answer: Equatable>(
        question: Question,
        answer: Answer,
        correctAnswers: [Question: Answer]
    ) -> Bool {
        answer == correctAnswers[question]
    }
    
    internal static func scoring<Question: Hashable, Answer: Equatable>(players: [Player<Question, Answer>], question: Question, correctAnswers: [Question: Answer]) {
        var playersWithRightAnswers = players.filter { $0.answers[question]?.answer == correctAnswers[question] }
        
        guard playersWithRightAnswers.count > 1 else {
            if let scoringPlayer = playersWithRightAnswers.first, let scoringIndex = players.firstIndex(of: scoringPlayer) {
                players[scoringIndex].score += 1
            }
            return
        }
        
        playersWithRightAnswers.sort {
            $0.answers[question]?.time ?? 0 < $1.answers[question]?.time ?? 0
        }
        
        if let fastestPlayer = playersWithRightAnswers.first, let fastestIndex = players.firstIndex(of: fastestPlayer) {
            players[fastestIndex].score += 1
        }
    }
}

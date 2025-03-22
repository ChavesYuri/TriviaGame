import Foundation
import XCTest
import QuizEngine

final class GameTest: XCTestCase {
    let router = RouterSpy()
    var game: Game<String, String, RouterSpy>!
    
    func test_startGame_firstPlayerAnswersCorrectlyAndSecondPlayerAnswerIncorrectly_firstPlayerScores1() {
        let players: [Player<String, String>] = [.init(name: "Player 1"), .init(name: "Player 2")]
        game =  startGame(players: players, questions: ["Q1"], router: router, correctAnswers: ["Q1": "A1"])
        
        router.playerTurnRequests[0].onStart()
        router.questionsRequests[0].answer("A1", 1)
        router.questionResultRequests[0].completion()
        router.playerTurnRequests[1].onStart()
        router.questionsRequests[1].answer("A2", 1)
        router.questionResultRequests[1].completion()
        router.roundResultRequests[0].completion()
        
        XCTAssertEqual(router.roundResultRequests[0].players[0].score, 1)
        XCTAssertEqual(router.roundResultRequests[0].players[1].score, 0)
    }
    
    func test_startGame_secondPlayerAnswersCorrectlyAndFirstPlayerAnswerIncorrectly_secondPlayerScores1() {
        let players: [Player<String, String>] = [.init(name: "Player 1"), .init(name: "Player 2")]
        game =  startGame(players: players, questions: ["Q1"], router: router, correctAnswers: ["Q1": "A1"])
        
        router.playerTurnRequests[0].onStart()
        router.questionsRequests[0].answer("A2", 1)
        router.questionResultRequests[0].completion()
        router.playerTurnRequests[1].onStart()
        router.questionsRequests[1].answer("A1", 1)
        router.questionResultRequests[1].completion()
        router.roundResultRequests[0].completion()
        
        XCTAssertEqual(router.roundResultRequests[0].players[1].score, 1)
        XCTAssertEqual(router.roundResultRequests[0].players[0].score, 0)
    }
    
    func test_startGame_bothPlayersAnswerIncorrectly_nobodyScores() {
        let players: [Player<String, String>] = [.init(name: "Player 1"), .init(name: "Player 2")]
        game =  startGame(players: players, questions: ["Q1"], router: router, correctAnswers: ["Q1": "A1"])
        
        router.playerTurnRequests[0].onStart()
        router.questionsRequests[0].answer("A2", 1)
        router.questionResultRequests[0].completion()
        router.playerTurnRequests[1].onStart()
        router.questionsRequests[1].answer("A2", 1)
        router.questionResultRequests[1].completion()
        router.roundResultRequests[0].completion()
        
        XCTAssertEqual(router.roundResultRequests[0].players[1].score, 0)
        XCTAssertEqual(router.roundResultRequests[0].players[0].score, 0)
    }
    
    func test_startGame_bothPlayersAnswerCorrectlyButTheFirstOneWasQuicker_firstPlayerScores1() {
        let players: [Player<String, String>] = [.init(name: "Player 1"), .init(name: "Player 2")]
        game =  startGame(players: players, questions: ["Q1"], router: router, correctAnswers: ["Q1": "A1"])
        
        router.playerTurnRequests[0].onStart()
        let player1TimeTaken: TimeInterval = 0.5
        router.questionsRequests[0].answer("A1", player1TimeTaken)
        router.questionResultRequests[0].completion()
        router.playerTurnRequests[1].onStart()
        let player2TimeTaken: TimeInterval = 0.55
        router.questionsRequests[1].answer("A1", player2TimeTaken)
        router.questionResultRequests[1].completion()
        router.roundResultRequests[0].completion()
        
        XCTAssertEqual(router.roundResultRequests[0].players[0].score, 1)
        XCTAssertEqual(router.roundResultRequests[0].players[1].score, 0)
    }
    
    func test_startGame_bothPlayersAnswerCorrectlyButTheSecondOneWasQuicker_secondPlayerScores1() {
        let players: [Player<String, String>] = [.init(name: "Player 1"), .init(name: "Player 2")]
        game =  startGame(players: players, questions: ["Q1"], router: router, correctAnswers: ["Q1": "A1"])
        
        router.playerTurnRequests[0].onStart()
        let player1TimeTaken: TimeInterval = 0.56
        router.questionsRequests[0].answer("A1", player1TimeTaken)
        router.questionResultRequests[0].completion()
        router.playerTurnRequests[1].onStart()
        let player2TimeTaken: TimeInterval = 0.55
        router.questionsRequests[1].answer("A1", player2TimeTaken)
        router.questionResultRequests[1].completion()
        router.roundResultRequests[0].completion()
        
        XCTAssertEqual(router.roundResultRequests[0].players[0].score, 0)
        XCTAssertEqual(router.roundResultRequests[0].players[1].score, 1)
    }
    
    func test_startGame_firstPlayerWinsTheThreeFirstRounds_firstPlayerWinsTheGameAndRoutesToResult() {
        let players: [Player<String, String>] = [.init(name: "Player 1"), .init(name: "Player 2")]
        game =  startGame(players: players, questions: ["Q1", "Q2", "Q3"], router: router, correctAnswers: ["Q1": "A1", "Q2": "A2", "Q3": "A3"])
        
        /// Round 1
        router.playerTurnRequests[0].onStart()
        let player1TimeTaken: TimeInterval = 0.56
        router.questionsRequests[0].answer("A1", player1TimeTaken)
        router.questionResultRequests[0].completion()
        router.playerTurnRequests[1].onStart()
        let player2TimeTaken: TimeInterval = 0.55
        router.questionsRequests[1].answer("A2", player2TimeTaken)
        router.questionResultRequests[1].completion()
        router.roundResultRequests[0].completion()
        
        /// Round 2
        router.playerTurnRequests[2].onStart()
        let player1SecondTimeTaken: TimeInterval = 0.56
        router.questionsRequests[2].answer("A2", player1SecondTimeTaken)
        router.questionResultRequests[2].completion()
        router.playerTurnRequests[3].onStart()
        let player2SecondTimeTaken: TimeInterval = 0.55
        router.questionsRequests[3].answer("A1", player2SecondTimeTaken)
        router.questionResultRequests[3].completion()
        router.roundResultRequests[1].completion()
        
        /// Round 3
        router.playerTurnRequests[4].onStart()
        let player1ThirdTimeTaken: TimeInterval = 0.56
        router.questionsRequests[4].answer("A3", player1ThirdTimeTaken)
        router.questionResultRequests[4].completion()
        router.playerTurnRequests[5].onStart()
        let player2ThirdTimeTaken: TimeInterval = 0.55
        router.questionsRequests[5].answer("A1", player2ThirdTimeTaken)
        router.questionResultRequests[5].completion()
        router.roundResultRequests[2].completion()
        
        XCTAssertEqual(router.roundResultRequests[0].players[0].score, 3)
        XCTAssertEqual(router.roundResultRequests[0].players[1].score, 0)
        XCTAssertEqual(router.gameResultCallCount, 1)
    }
    
    func test_startGame_firstPlayerAnswersCorrectlyAndSecondPlayerAnswerIncorrectly_firstPlayerQuestionResulIsCorrectAndSecondIsIncorrect() {
        let players: [Player<String, String>] = [.init(name: "Player 1"), .init(name: "Player 2")]
        game =  startGame(players: players, questions: ["Q1"], router: router, correctAnswers: ["Q1": "A1"])
        
        router.playerTurnRequests[0].onStart()
        router.questionsRequests[0].answer("A1", 1)
        router.questionResultRequests[0].completion()
        router.playerTurnRequests[1].onStart()
        router.questionsRequests[1].answer("A2", 1)
        router.questionResultRequests[1].completion()
        router.roundResultRequests[0].completion()
        
        XCTAssertTrue(router.questionResultRequests[0].result.isCorrect)
        XCTAssertFalse(router.questionResultRequests[1].result.isCorrect)
    }
    
    func test_startGame_bothAnswerCorrectly_bothResultAreCorrect() {
        let players: [Player<String, String>] = [.init(name: "Player 1"), .init(name: "Player 2")]
        game =  startGame(players: players, questions: ["Q1"], router: router, correctAnswers: ["Q1": "A1"])
        
        router.playerTurnRequests[0].onStart()
        router.questionsRequests[0].answer("A1", 1)
        router.questionResultRequests[0].completion()
        router.playerTurnRequests[1].onStart()
        router.questionsRequests[1].answer("A1", 1)
        router.questionResultRequests[1].completion()
        router.roundResultRequests[0].completion()
        
        XCTAssertTrue(router.questionResultRequests[0].result.isCorrect)
        XCTAssertTrue(router.questionResultRequests[1].result.isCorrect)
    }
}

import Foundation
import XCTest
import QuizEngine

final class FlowTest: XCTestCase {
    func test_start_noQuestionsAndOnePlayer_routesToGameResult() {
        let (sut, routerSpy) = makeSUT(questions: [], players: [.init(name: "a player")])
        
        sut.start()
        
        XCTAssertTrue(routerSpy.questionsRequests.isEmpty)
        XCTAssertTrue(routerSpy.questionsRequests.isEmpty)
        XCTAssertEqual(routerSpy.gameResultCallCount, 1)
    }
    
    func test_start_withOneQuestionAndNoPlayers_routesToGameResult() {
        let (sut, routerSpy) = makeSUT(questions: ["Q1"], players: [])
        
        sut.start()
        
        XCTAssertTrue(routerSpy.questionsRequests.isEmpty)
        XCTAssertTrue(routerSpy.questionsRequests.isEmpty)
        XCTAssertEqual(routerSpy.gameResultCallCount, 1)
    }
    
    func test_start_withNoQuestionAndNoPlayers_routesToGameResult() {
        let (sut, routerSpy) = makeSUT(questions: [], players: [])
        
        sut.start()
        
        XCTAssertTrue(routerSpy.questionsRequests.isEmpty)
        XCTAssertTrue(routerSpy.questionsRequests.isEmpty)
        XCTAssertEqual(routerSpy.gameResultCallCount, 1)
    }
    
    func test_start_withOneQuestionAndOnePlayer_routesToFirstPlayerTurn() {
        let players: [Player] = [.init(name: "a player")]
        let (sut, routerSpy) = makeSUT(questions: ["Q1"], players: players)
        
        sut.start()
        
        XCTAssertEqual(routerSpy.playerTurnRequests[0].player, players[0])
        XCTAssertEqual(routerSpy.gameResultCallCount, 0)
        XCTAssertTrue(routerSpy.questionsRequests.isEmpty)
    }
    
    func test_startAndFirstPlayerInitiatesGame_withOneQuestionAndOnePlayer_routesToFirstQuestion() {
        let players: [Player] = [.init(name: "a player")]
        let (sut, routerSpy) = makeSUT(questions: ["Q1"], players: players)
        
        sut.start()
        routerSpy.playerTurnRequests[0].onStart()
        
        XCTAssertEqual(routerSpy.playerTurnRequests[0].player, players[0])
        XCTAssertEqual(routerSpy.gameResultCallCount, 0)
        XCTAssertEqual(routerSpy.questionsRequests.count, 1)
        XCTAssertEqual(routerSpy.questionsRequests.first?.question, "Q1")
    }
    
    func test_startAndFirstPlayerInitiatesGameAndAnswersFirstQuestion_withOneQuestionAndOnePlayer_routesToQuestionResult() {
        let players: [Player] = [.init(name: "a player")]
        let (sut, routerSpy) = makeSUT(questions: ["Q1"], players: players)
        
        sut.start()
        routerSpy.playerTurnRequests[0].onStart()
        routerSpy.questionsRequests[0].answer("A answer")
        
        XCTAssertEqual(routerSpy.questionsRequests.count, 1)
        XCTAssertEqual(routerSpy.questionsRequests.first?.question, "Q1")
        XCTAssertEqual(routerSpy.questionResultRequests.count, 1)
    }
    
    func test_startAndFirstPlayerStartsAndAnswersQuestionAndCompletesQuestionResult_withOneQuestionAndOnePlayer_routesToGameResult() {
        let players: [Player] = [.init(name: "a player")]
        let (sut, routerSpy) = makeSUT(questions: ["Q1"], players: players)
        
        sut.start()
        routerSpy.playerTurnRequests[0].onStart()
        routerSpy.questionsRequests[0].answer("A answer")
        routerSpy.questionResultRequests[0]()
        
        XCTAssertEqual(routerSpy.gameResultCallCount, 1)
    }
    
    func test_startAndFirstPlayerStartsAndAnswersQuestionAndCompletesQuestionResult_withTwoQuestionAndOnePlayer_routesToNextQuestionWithFirstPlayer() {
        let players: [Player] = [.init(name: "a player")]
        let (sut, routerSpy) = makeSUT(questions: ["Q1", "Q2"], players: players)
        
        sut.start()
        routerSpy.playerTurnRequests[0].onStart()
        routerSpy.questionsRequests[0].answer("A answer")
        routerSpy.questionResultRequests[0]()
        
        XCTAssertEqual(routerSpy.questionsRequests.count, 2)
        XCTAssertEqual(routerSpy.questionsRequests[0].question, "Q1")
        XCTAssertEqual(routerSpy.questionsRequests[1].question, "Q2")
    }
    
    func test_startAndFirstPlayerStartsAndAnswersQuestionAndCompletesQuestionResult_withOneQuestionAndTwoPlayers_routesToNextPlayerTurnWithSecondPlayer() {
        let players: [Player] = [.init(name: "a player"), .init(name: "Another Player")]
        let (sut, routerSpy) = makeSUT(questions: ["Q1"], players: players)
        
        sut.start()
        routerSpy.playerTurnRequests[0].onStart()
        routerSpy.questionsRequests[0].answer("A answer")
        routerSpy.questionResultRequests[0]()
        
        XCTAssertEqual(routerSpy.questionsRequests.count, 1)
        XCTAssertEqual(routerSpy.questionsRequests[0].question, "Q1")
        XCTAssertEqual(routerSpy.playerTurnRequests.count, 2)
        XCTAssertEqual(routerSpy.playerTurnRequests[0].player, players[0])
        XCTAssertEqual(routerSpy.playerTurnRequests[1].player, players[1])
    }
    
    // MARK: Helpers
    
    private func makeSUT(
        questions: [String] = [],
        players: [Player] = []
    ) -> (Flow, RouterSpy) {
        let routerSpy = RouterSpy()
        let sut = Flow(players: players, router: routerSpy, questions: questions)
        
        return (sut, routerSpy)
    }
    
    final class RouterSpy: Router {
        private(set) var playerTurnRequests: [(player: Player, onStart: () -> Void)] = []
        
        func routeToPlayerTurn(player: Player, _ onStart: @escaping () -> Void) {
            playerTurnRequests.append((player, onStart))
        }
        
        private(set) var questionsRequests: [(question: Question, answer: Answer)] = []
        
        func routeToQuestionScreen(_ question: Question, _ answer: @escaping Answer) {
            questionsRequests.append((question, answer))
        }
        
        private(set) var questionResultRequests: [() -> Void] = []
        
        func routeToQuestionResult(completion: @escaping () -> Void) {
            questionResultRequests.append(completion)
        }
        
        private(set) var gameResultCallCount = 0
        
        func routeToGameResult() {
            gameResultCallCount += 1
        }
    }
    
}

import Foundation
import XCTest
import QuizEngine

final class FlowTest: XCTestCase {
    func test_start_noQuestionsAndOnePlayer_routesToGameResult() {
        let (sut, routerSpy) = makeSUT(questions: [], players: [.init(name: "a player")])
        
        sut.start()
        
        XCTAssertTrue(routerSpy.routedQuestionsRequests.isEmpty)
        XCTAssertTrue(routerSpy.routedQuestionsRequests.isEmpty)
        XCTAssertEqual(routerSpy.routedToGameResultCallCount, 1)
    }
    
    func test_start_withOneQuestionAndNoPlayers_routesToGameResult() {
        let (sut, routerSpy) = makeSUT(questions: ["Q1"], players: [])
        
        sut.start()
        
        XCTAssertTrue(routerSpy.routedQuestionsRequests.isEmpty)
        XCTAssertTrue(routerSpy.routedQuestionsRequests.isEmpty)
        XCTAssertEqual(routerSpy.routedToGameResultCallCount, 1)
    }
    
    func test_start_withNoQuestionAndNoPlayers_routesToGameResult() {
        let (sut, routerSpy) = makeSUT(questions: [], players: [])
        
        sut.start()
        
        XCTAssertTrue(routerSpy.routedQuestionsRequests.isEmpty)
        XCTAssertTrue(routerSpy.routedQuestionsRequests.isEmpty)
        XCTAssertEqual(routerSpy.routedToGameResultCallCount, 1)
    }
    
    func test_start_withOneQuestionAndOnePlayer_routesToFirstPlayerTurn() {
        let players: [Player] = [.init(name: "a player")]
        let (sut, routerSpy) = makeSUT(questions: ["Q1"], players: players)
        
        sut.start()
        
        XCTAssertEqual(routerSpy.routedToPlayerTurnRequests[0].player, players[0])
        XCTAssertEqual(routerSpy.routedToGameResultCallCount, 0)
        XCTAssertTrue(routerSpy.routedQuestionsRequests.isEmpty)
    }
    
    func test_startAndFirstPlayerInitiatesGame_withOneQuestionAndOnePlayer_routesToFirstQuestion() {
        let players: [Player] = [.init(name: "a player")]
        let (sut, routerSpy) = makeSUT(questions: ["Q1"], players: players)
        
        sut.start()
        routerSpy.routedToPlayerTurnRequests[0].onStart()
        
        XCTAssertEqual(routerSpy.routedToPlayerTurnRequests[0].player, players[0])
        XCTAssertEqual(routerSpy.routedToGameResultCallCount, 0)
        XCTAssertEqual(routerSpy.routedQuestionsRequests.count, 1)
        XCTAssertEqual(routerSpy.routedQuestionsRequests.first?.question, "Q1")
    }
    
    private func makeSUT(
        questions: [String] = [],
        players: [Player] = []
    ) -> (Flow, RouterSpy) {
        let routerSpy = RouterSpy()
        let sut = Flow(players: players, router: routerSpy, questions: questions)
        
        return (sut, routerSpy)
    }
    
    final class RouterSpy: Router {
        var routedToGameResultCallCount = 0
        var routedQuestionsRequests: [(question: Question, completion: Answer)] = []
        var routedToPlayerTurnRequests: [(player: Player, onStart: () -> Void)] = []
        
        func routeToPlayerTurn(player: Player, _ onStart: @escaping () -> Void) {
            routedToPlayerTurnRequests.append((player, onStart))
        }
        
        func routeToQuestionScreen(_ question: Question, _ answer: @escaping Answer) {
            routedQuestionsRequests.append((question, answer))
        }
        
        func routeToQuestionResult() {}
        
        func routeToGameResult() {
            routedToGameResultCallCount += 1
        }
    }
    
}

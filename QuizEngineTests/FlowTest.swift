import Foundation
import XCTest
import QuizEngine

final class FlowTest: XCTestCase {
    func test_start_noQuestions_routesToResult() {
        let (sut, routerSpy) = makeSUT(questions: [])
        
        sut.start()
        
        XCTAssertTrue(routerSpy.routedQuestions.isEmpty)
        XCTAssertEqual(routerSpy.routedToResultCallCount, 1)
    }
    
    private func makeSUT(
        questions: [String] = []
    ) -> (Flow, RouterSpy) {
        let routerSpy = RouterSpy()
        let sut = Flow(router: routerSpy, questions: questions)
        
        return (sut, routerSpy)
    }
    
    final class RouterSpy: Router {
        var routedToResultCallCount = 0
        var routedQuestions: [Question] = []
        
        func routeTo(question: Question) {
            routedQuestions.append(question)
        }
        
        func routeToResult() {
            routedToResultCallCount += 1
        }
    }
    
}

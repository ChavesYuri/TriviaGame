import Foundation

public protocol Router {
    typealias Question = String
    func routeTo(question: Question)
    func routeToResult()
}

public final class Flow {
    private let router: Router
    private let questions: [String]
    
    public init(router: Router, questions: [String]) {
        self.router = router
        self.questions = questions
    }
    
    public func start() {
        if let firstQuestion = questions.first {
            router.routeTo(question: firstQuestion)
        } else {
            router.routeToResult()
        }
    }
}

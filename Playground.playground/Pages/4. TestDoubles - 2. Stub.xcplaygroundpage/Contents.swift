struct Post {
    let title: String
    let text: String
}

protocol PostsServiceProtocol {
    func fetchAll(then: (Result<[Post], Error>) -> Void)
}

final class UserFeedViewModel {
    
    private let postsService: PostsServiceProtocol
    private(set) var numberOfPosts: Int = 0
    
    init(postsService: PostsServiceProtocol) {
        self.postsService = postsService
    }
    
    func loadData(then: @escaping () -> Void) {
        postsService.fetchAll { [weak self] result in
            let numberOfPosts = (try? result.get())?.count ?? 0
            self?.numberOfPosts = numberOfPosts
            then()
        }
    }
    
}

final class PostsServiceStub: PostsServiceProtocol {
    var fetchAllResultToBeReturned: Result<[Post], Error> = .success([])
    func fetchAll(then: (Result<[Post], Error>) -> Void) {
        then(fetchAllResultToBeReturned)
    }
}

// Usage
import XCTest

final class UserFeedViewModelTests: XCTestCase {
    
    func test_fetchAll_shouldReturnTheCorrectAmountOfPosts() {
        
        // Given
        let postsServiceStub = PostsServiceStub()
        let stubbedPosts: [Post] = [
            .init(title: "Post 1", text: "Post Text 1"),
            .init(title: "Post 2", text: "Post Text 2")
        ]
        postsServiceStub.fetchAllResultToBeReturned = .success(stubbedPosts)
        let sut = UserFeedViewModel(postsService: postsServiceStub)
        let initialNumberOfPosts = sut.numberOfPosts
        
        // When
        let loadDataExpectation = expectation(description: "loadDataExpectation")
        sut.loadData {
            loadDataExpectation.fulfill()
        }
        wait(for: [loadDataExpectation], timeout: 1.0)
        
        // Then
        XCTAssertNotEqual(initialNumberOfPosts, sut.numberOfPosts)
    }
    
}

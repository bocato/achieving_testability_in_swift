import XCTest

struct User: Equatable {
    let name: String
    let password: String
}

protocol UserServiceProtocol {
    func login(_ user: User, then: (Result<Void, Error>) -> Void)
}
protocol SafeStorageProtocol {
    func storeUserData(_ user: User)
}

final class LoginViewModel {
    private let userService: UserServiceProtocol
    private let safeStorage: SafeStorageProtocol
    
    init(
        userService: UserServiceProtocol,
        safeStorage: SafeStorageProtocol
    ) {
        self.userService = userService
        self.safeStorage = safeStorage
    }
    
    func performLoginForUser(_ user: User) {
        userService.login(user) { [weak self] result in
            switch result {
            case .success:
                self?.safeStorage.storeUserData(user)
            case let .failure(error):
                // do something with the error
                debugPrint(error)
            }
        }
    }
}

// Usage
final class UserServiceStub: UserServiceProtocol {
    
    var loginResultToBeReturned: Result<Void, Error> = .success(())
    func login(_ user: User, then: (Result<Void, Error>) -> Void) {
        then(loginResultToBeReturned)
    }
    
}

final class SafeStorageSpy: SafeStorageProtocol {
    private(set) var storeUserDataCalled = false
    private(set) var userPassed: User?
    func storeUserData(_ user: User) {
        storeUserDataCalled = true
        userPassed = user
    }
}

// Usage
final class LoginViewModelTests: XCTestCase {
    func test_fetchAll_shouldReturnTheCorrectAmountOfPosts() {
        // Given
        let userServiceStub = UserServiceStub()
        userServiceStub.loginResultToBeReturned = .success(())
        let safeStorageSpy = SafeStorageSpy()
        let sut = LoginViewModel(
            userService: userServiceStub,
            safeStorage: safeStorageSpy
        )
        let userMock = User(name: "name", password: "password")
        
        // When
        sut.performLoginForUser(userMock)
        
        // Then
        XCTAssertTrue(safeStorageSpy.storeUserDataCalled)
        XCTAssertEqual(userMock, safeStorageSpy.userPassed)
    }
}

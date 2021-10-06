import XCTest

struct SessionData {
    let email: String
    let token: String
}

typealias SessionToken = String

protocol UserServiceProtocol {
    func login(email: String, password: String, then completion: (Result<SessionToken, Error>) -> Void)
}

enum StorageKeys {
    static let sessionToken = "session_token_key"
}

protocol SecureStorageProtocol {
    func save<T: Encodable>(_ value: T, inKey key: String) throws
    func retrieveValue<T: Decodable>(ofType: T.Type, fromKey key: String) throws -> T?
}

final class LoginViewModel {
    
    private let userService: UserServiceProtocol
    private let secureStorage: SecureStorageProtocol
    
    init(userService: UserServiceProtocol, secureStorage: SecureStorageProtocol) {
        self.userService = userService
        self.secureStorage = secureStorage
    }
    
    func performLogin(
        email: String,
        password: String,
        then completion: @escaping (Result<Void, Error>) -> Void
    ) {
        userService.login(email: email, password: password) { [secureStorage] result in
            switch result {
            case let .success(token):
                do {
                    try secureStorage.save(token, inKey: StorageKeys.sessionToken)
                    completion(.success(()))
                } catch {
                    completion(.failure(error))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
}

// Usage

final class UserServiceStub: UserServiceProtocol {
    init() {}
    var loginResultToBeReturned: Result<SessionToken, Error> = .success("some_token")
    func login(email: String, password: String, then completion: (Result<SessionToken, Error>) -> Void) {
        completion(loginResultToBeReturned)
    }
}

final class SecureStorageFake: SecureStorageProtocol {
    init() {}
    private(set) var storage: [String: Any] = [:]
    
    func save<T>(_ value: T, inKey key: String) throws where T : Encodable {
        storage[key] = value
    }
    
    func retrieveValue<T>(ofType: T.Type, fromKey key: String) throws -> T? where T : Decodable {
        return storage[key] as? T
    }
}

final class LoginViewModelTests: XCTestCase {
    func test_performLogin_whenSucceeded_shouldSaveTokenOnSecureStorage() {
        // Given
        let tokenMock: SessionToken = "user_token"
        let userServiceStub: UserServiceStub = .init()
        userServiceStub.loginResultToBeReturned = .success(tokenMock)
        
        let secureStorageFake: SecureStorageFake = .init()
        
        let sut = LoginViewModel(
            userService: userServiceStub,
            secureStorage: secureStorageFake
        )
        
        // When
        let performLoginExpectation = expectation(description: "performLoginExpectation")
        sut.performLogin(email: "whatever", password: "don't care") { _ in
            performLoginExpectation.fulfill()
        }
        wait(for: [performLoginExpectation], timeout: 1.0)
        
        // Then
        let storedToken = try? secureStorageFake.retrieveValue(ofType: SessionToken.self, fromKey: StorageKeys.sessionToken)
        XCTAssertEqual(storedToken, tokenMock)
    }
}




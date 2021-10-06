import Foundation

/// Common Singleton Example
struct LoggedUser {
    let id: String
    let username: String
    let token: String
}

struct LoginResponse {
    let id: String
    let token: String
}

final class UserSesssion {
    // MARK: - Shared Instance
    
    static let shared = UserSesssion()
    
    // MARK: - Public Properties
    
    private(set) var currentUser: LoggedUser?
    var isValid: Bool { currentUser?.token.isEmpty == false }
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Public API
    
    func login(
        username: String,
        password: String,
        then completion: @escaping (Result<Void, Error>) -> Void
    ) {
        dispatchLoginRequest(username: username, password: password) { [weak self] result in
            do {
                let response = try result.get()
                self?.currentUser = .init(id: response.id, username: username, token: response.token)
                completion(.success(()))
            } catch {
                self?.currentUser = nil
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Private API
    
    private func dispatchLoginRequest(
        username: String,
        password: String,
        then completion: @escaping (Result<LoginResponse, Error>) -> Void
    ) { /* ... */ }
}

/// Dependencies Singleton Example

protocol UserSesssionProtocol {
    var currentUser: LoggedUser? { get }
    var isValid: Bool { get }
    func login(
        username: String,
        password: String,
        then completion: @escaping (Result<Void, Error>) -> Void
    )
}
extension UserSesssion: UserSesssionProtocol {}

protocol AppEnvironmentProtocol {
    var urlSession: URLSession { get }
    var userDefaults: UserDefaults { get }
    var userSession: UserSesssionProtocol { get }
}

final class AppEnvironment: AppEnvironmentProtocol {
    static let shared = AppEnvironment()
    
    private(set) var urlSession: URLSession
    private(set) var userDefaults: UserDefaults
    private(set) var userSession: UserSesssionProtocol
    
    private init() {
        self.urlSession = .shared
        self.userDefaults = .standard
        self.userSession = UserSesssion.shared
    }
}

final class SomeViewModel {
    // MARK: - Dependencies
    
    private let appEnvironment: AppEnvironmentProtocol
    
    // MARK: - Initialization
    
    init(appEnvironment: AppEnvironmentProtocol = AppEnvironment.shared) {
        self.appEnvironment = appEnvironment
    }
    
    // MARK: - Public API
    // Functions that use something from the environment...
}

/// Singleton + or Singleton Extended

final class PersistencyManager {
    // MARK: - Shared Instance
    
    static let shared = PersistencyManager(userDefaults: .standard)
    
    // MARK: - Dependencies
    
    private let userDefaults: UserDefaults
    
    // MARK: - Public Properties
    
    private(set) var values: [String] = []
    
    // MARK: - Initialization
    
    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
    
    // MARK: - Public Functions
    
    func save(_ value: String) -> Bool {
        var newValues = values
        newValues.append(value)
        
        userDefaults.set(value, forKey: "valuesKey")
        
        let sincronizationSucceeded = userDefaults.synchronize()
        if sincronizationSucceeded { values = newValues }
        return sincronizationSucceeded
    }
    
    /* ... */
}

import XCTest

final class DefaultsManagerTests: XCTestCase {

    func test_whenAddIsCalled_userDefaultsShouldReceiveValue_andSyncronize() {
        // Given
        let userDefaultsSpy = UserDefaultsSpy()
        let sut = PersistencyManager(
            userDefaults: userDefaultsSpy
        )
        let valueToAdd = "some value"
        // When
        let addSucceeded = sut.save(valueToAdd)
        // Then
        XCTAssertTrue(addSucceeded)
        XCTAssertTrue(userDefaultsSpy.setValueCalled)
        XCTAssertEqual(1, sut.values.count)
        XCTAssertTrue(userDefaultsSpy.synchronizeCalled)
    }

}

final class UserDefaultsSpy: UserDefaults {
    
    private(set) var setValueCalled = false
    private(set) var setValuePassed: Any?
    private(set) var setValueKeyPassed: String?
    
    override func set(_ value: Any?, forKey defaultName: String) {
        setValueCalled = true
        setValuePassed = value
        setValueKeyPassed = defaultName
    }
    
    private(set) var synchronizeCalled = false
    override func synchronize() -> Bool {
        synchronizeCalled = true
        return true
    }
    
}






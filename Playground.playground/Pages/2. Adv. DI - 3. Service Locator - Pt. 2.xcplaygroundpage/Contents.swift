import Foundation

final class DependencyContainer {
    static let shared = DependencyContainer()
    
    private var instances: [String: Any] = [:]
    
    func register<T>(
        instance: T,
        forMetaType metaType: T.Type
    ) {
        let key = String(describing: metaType)
        instances[key] = instance
    }
    
    func autoResolve<T>(
        file: StaticString = #file,
        line: UInt = #line
    ) -> T {
        let key = String(describing: T.self)
        guard let instance = instances[key] as? T else {
            fatalError("There is no instance registered for `\(key)`!", file: file, line: line)
        }
        return instance
    }
}

@propertyWrapper
final class Dependency<T> {
    private(set) var resolvedValue: T!
    
    // MARK: - Properties
    var wrappedValue: T {
        resolveIfNeeded()
        return resolvedValue!
    }
    
    // MARK: - Initialization
    convenience init() {
        self.init(resolvedValue: nil)
    }
    
    fileprivate init(resolvedValue: T?) {
        self.resolvedValue = resolvedValue
    }
    
    private func resolveIfNeeded() {
        guard resolvedValue == nil else { return }
        resolvedValue = DependencyContainer.shared.autoResolve()
    }
}
//#if DEBUG
extension Dependency {
    static func resolved(_ value: T) -> Self {
        .init(resolvedValue: value)
    }
}
//#endif

protocol LoginServiceProtocol { /* ... */ }
final class LoginService: LoginServiceProtocol {
    init() {}
}

protocol UserSessionProtocol { /* ... */ }
final class UserSession: UserSessionProtocol {
    init() {}
}

final class AppDelegate {
    var dependencyContainer: DependencyContainer = .shared
    func application(
//        _ application: UIApplication,
//        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        registerDependencies()
        return true
    }
    
    private func registerDependencies() {
        dependencyContainer.register(instance: LoginService(), forMetaType: LoginServiceProtocol.self)
        dependencyContainer.register(instance: UserSession(), forMetaType: UserSessionProtocol.self)
    }
}

struct LoginViewEnvironment {
    @Dependency var loginService: LoginServiceProtocol
    @Dependency var userSession: UserSessionProtocol
}

final class LoginViewModel {
    private let environment: LoginViewEnvironment
    init(environment: LoginViewEnvironment) {
        self.environment = environment
    }
    
    // ...
}

//#if DEBUG
extension LoginViewEnvironment {
    static func mocking(
        loginService: LoginServiceProtocol,
        userSession: UserSessionProtocol
    ) -> Self {
        .init(
            loginService: .resolved(loginService),
            userSession: .resolved(userSession)
        )
    }
}
//#endif

import XCTest

struct LoginServiceMock: LoginServiceProtocol {}
struct UserSessionMock: UserSessionProtocol {}

final class LoginViewModelTests: XCTestCase {
    func test_something() {
        // Given
        let sut: LoginViewModel = .init(
            environment: .mocking(
                loginService: LoginServiceMock(),
                userSession: UserSessionMock()
            )
        )
        _ = sut // ... Test your stuff!
    }
}






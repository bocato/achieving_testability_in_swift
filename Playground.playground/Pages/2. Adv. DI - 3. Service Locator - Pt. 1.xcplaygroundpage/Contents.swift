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
    
    func resolve<T>(
        _ metaType: T.Type,
        file: StaticString = #file,
        line: UInt = #line
    ) -> T {
        let key = String(describing: metaType)
        guard let instance = instances[key] as? T else {
            fatalError("There is no instance registered for `\(key)`!", file: file, line: line)
        }
        return instance
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

final class LoginViewModel {
    private let loginService: LoginServiceProtocol
    private let userSession: UserSessionProtocol
    
    init(
        loginService: LoginServiceProtocol? = nil,
        userSession: UserSessionProtocol? = nil
    ) {
        self.loginService = loginService ?? DependencyContainer.shared.autoResolve()
        self.userSession = userSession ?? DependencyContainer.shared.resolve(UserSessionProtocol.self)
    }
    
    // ...
}


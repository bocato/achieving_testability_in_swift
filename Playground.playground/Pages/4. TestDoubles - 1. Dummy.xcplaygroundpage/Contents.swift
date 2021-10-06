import Foundation

struct User {}

protocol UserServiceProtocol {
    func login(_ user: User, then: (Result<Void, Error>) -> Void)
}

struct UserServiceDummy: UserServiceProtocol {
    func login(_ user: User, then: (Result<Void, Error>) -> Void) {
        // Do nothing.
    }
}

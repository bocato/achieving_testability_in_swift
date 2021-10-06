import XCTest

protocol NetworkProtocol {
    func getData(from url: URL, then: (Result<Data?, Error>) -> Void)
}
final class Network: NetworkProtocol {
    static let shared = Network()
    func getData(from url: URL, then: (Result<Data?, Error>) -> Void) { /* ... */ }
}

struct User { /* ... */ }
final class UserService {
    
    private let network: NetworkProtocol
    
    init(network: NetworkProtocol = Network.shared) {
        self.network = network
    }
    
    func getUserData(then: @escaping (Result<User, Error>) -> Void) {
        network.getData(from: URL(string: "www.data.com/some")!) { result in
            /* ... */
        }
    }
    
}

import XCTest
import UIKit

protocol NetworkProtocol {
    func getData(from url: URL, then: (Result<Data?, Error>) -> Void)
}
final class Network: NetworkProtocol {
    static let shared = Network()
    func getData(from url: URL, then: (Result<Data?, Error>) -> Void) { /* ... */ }
}

extension UIImageView {
    
    func setImageFromURL(_ url: URL, network: NetworkProtocol = Network.shared) {
        network.getData(from: url) { result in
            guard
                let data = try? result.get(),
                let remoteImage = UIImage(data: data)
            else { return }
            DispatchQueue.main.async { self.image = remoteImage }
        }
    }
    
}

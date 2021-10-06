import XCTest

protocol NetworkProtocol {
    func getData(from url: URL, then: (Result<Data?, Error>) -> Void)
}
final class Network: NetworkProtocol {
    static let shared = Network()
    func getData(from url: URL, then: (Result<Data?, Error>) -> Void) { /* ... */ }
}

final class ViewController: UIViewController {
    
    var network: NetworkProtocol = Network.shared
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    func loadData() {
        network.getData(from: URL(string: "www.data.com/some")!) { result in
            /* ... */
        }
    }
    
}












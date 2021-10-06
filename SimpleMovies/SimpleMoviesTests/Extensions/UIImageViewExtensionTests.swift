import XCTest
@testable import SimpleMovies

final class UIImageViewExtensionTests: XCTestCase {
    
    // Using:
    // -> Parameter-based Injection
    // -> Stubs
    func test_whenNetworkFails_errorImageShouldBeSet() {
        // Given
        let networkStub = NetworkStub()
        networkStub.resultToReturn = .failure(.unknown)
        let frame = CGRect(origin: .zero, size: .init(width: 10, height: 10))
        let sut = UIImageView(frame: frame)
        let expectedErrorImage: UIImage? = .noImage
        XCTAssertNil(sut.image)
        
        // When
        sut.setImageFromURL(
            "www.mock.com",
            using: networkStub
        )
        
        // Then
        XCTAssertEqual(sut.image, expectedErrorImage)
    }
    
}

// MARK: - Testing Helpers

final class NetworkStub: NetworkProtocol {
    
    var resultToReturn: Result<Data?, NetworkError> = .success(nil)
    var dataTaskToReturn: URLSessionDataTask?
    func getData(
        from url: URL,
        onQueue queue: DispatchQueue,
        then: @escaping (Result<Data?, NetworkError>) -> Void
    ) -> URLSessionDataTask {
        then(resultToReturn)
        return dataTaskToReturn ?? URLSession.shared.dataTask(with: url)
    }
    
}

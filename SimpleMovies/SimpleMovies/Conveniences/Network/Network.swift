import Foundation

enum NetworkError: Error {
    case api(OMDBError)
    case raw(Error)
    case unexpected
    case unknown
}

struct OMDBError: Codable {
    let response: String
    let error: String
    
    enum CodingKeys: String, CodingKey {
        case response = "Response"
        case error = "Error"
    }
    
    static let unknown = OMDBError(response: "False", error: "Unknown error.")
}

final class Network {
    
    // MARK: - Singleton
    
    static let shared = Network()
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Constants
    
    private let defaultHeaders = ["content-type": "application/json"]
    
    // MARK: - Public Functions
    
    @discardableResult
    func getData(
        from url: URL,
        onQueue queue: DispatchQueue = .main,
        then: @escaping (Result<Data?, NetworkError>) -> Void
    ) -> URLSessionDataTask {
        
        let request = createGetRequest(for: url)
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            queue.async {
                self?.handleDataTaskCompletion(
                    data: data,
                    response: response,
                    error: error,
                    then: then
                )
            }
        }
        task.resume()
        
        return task
    }
    
    // MARK: - Private Functions
    
    private func createGetRequest(for url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = defaultHeaders
        return request
    }
    
    private func handleDataTaskCompletion(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        then: @escaping (Result<Data?, NetworkError>) -> Void
    ) {
         
        let httpURLResponse = response as? HTTPURLResponse
        
        guard let statusCode = httpURLResponse?.statusCode else {
            then(.failure(.unexpected))
            return
        }
        
        if let rawError = error {
            then(.failure(.raw(rawError)))
            return
        }
         
        guard 200...299 ~= statusCode else {
            handleHTTPErrors(
                statusCode: statusCode,
                data: data,
                response: httpURLResponse,
                then: then
            )
            return
        }
        
        if let data = data, let apiError = try? JSONDecoder().decode(OMDBError.self, from: data) {
            then(.failure(.api(apiError)))
            return
        }
        
        then(.success(data))
         
    }
    
    private func handleHTTPErrors(
        statusCode: Int,
        data: Data?,
        response: HTTPURLResponse?,
        then: @escaping (Result<Data?, NetworkError>) -> Void
    ) {
        
        guard let data = data, 400...499 ~= statusCode else {
            then(.failure(.unexpected))
            return
        }
        
        let apiError = try? JSONDecoder().decode(OMDBError.self, from: data)
        then(.failure(.api(apiError ?? .unknown)))
        
    }
    
}

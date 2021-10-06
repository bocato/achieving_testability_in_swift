import Foundation

enum MoviesServiceError: Error {
    case invalidURL
    case decodingError(Error)
    case network(Error)
    case api(OMDBError)
}

protocol MoviesServiceProtocol {
    func searchMovies(
        withTitle title: String,
        then: @escaping (Result<[SearchResponse.Result], MoviesServiceError>) -> Void
    )
}
final class MoviesService: MoviesServiceProtocol {
    
    func searchMovies(
        withTitle title: String,
        then: @escaping (Result<[SearchResponse.Result], MoviesServiceError>) -> Void
    ) {
        
        let queryItems: [String: String] = [
            "apiKey": Constants.apiKey,
            "s": title
        ]
        
        var urlComponents = URLComponents(url: Constants.moviesURL, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = queryItems.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        guard let url = urlComponents?.url else {
            then(.failure(.invalidURL))
            return
        }
        
        Network.shared.getData(from: url) { result in
            switch result {
            case let .success(data):
                guard let data = data else {
                    then(.success([]))
                    return
                }
                
                do {
                    let decodedValue = try JSONDecoder().decode(SearchResponse.self, from: data)
                    let movies = decodedValue.results.filter { $0.type == .movie }
                    then(.success(movies))
                } catch {
                    then(.failure(.decodingError(error)))
                }
            case let .failure(networkError):
                switch networkError {
                case let .api(apiError):
                    then(.failure(.api(apiError)))
                default:
                    then(.failure(.network(networkError)))
                }
            }
        }
        
    }
    
}

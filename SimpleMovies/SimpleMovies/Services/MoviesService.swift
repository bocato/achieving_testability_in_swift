import Foundation

enum MoviesServiceError: Error {
    case invalidURL
    case decodingError(Error)
    case network(Error)
    case api(OMDBError)
}

final class MoviesService {
    
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
                    then(.success(decodedValue.results))
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

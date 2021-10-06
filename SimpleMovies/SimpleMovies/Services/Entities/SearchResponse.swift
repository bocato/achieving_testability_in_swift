import Foundation

struct SearchResponse: Codable {
    let results: [Result]
    let totalResults, response: String

    enum CodingKeys: String, CodingKey {
        case results = "Search"
        case totalResults
        case response = "Response"
    }
}
extension SearchResponse {
    struct Result: Codable {
        let title, year, imdbID: String
        let type: TypeEnum
        let poster: String

        enum CodingKeys: String, CodingKey {
            case title = "Title"
            case year = "Year"
            case imdbID
            case type = "Type"
            case poster = "Poster"
        }
    }
}
extension SearchResponse.Result {
    enum TypeEnum: String, Codable {
        case movie = "movie"
        case series = "series"
    }
}


import XCTest
@testable import SimpleMovies

final class ListViewControllerTests: XCTestCase {
    
    // Using:
    // - Initializer-based Injection
    // - Spies
    func test_whenViewDidLoad_isCalled_favoritesShouldBeLoaded() {
        // Given
        let favoritesManagerSpy = FavoritesManagerSpy()
        let sut = ListViewController(favoritesManager: favoritesManagerSpy)
        _ = sut.view // trick to force load the view
        
        // When
        sut.viewDidLoad()
        
        // Then
        XCTAssertTrue(favoritesManagerSpy.loadCalled)
    }
    
    // Using:
    // - Initializer-based Injection
    // - Stubs, Dummy, Reflection
    func test_whenAValidMovieIsSearched_successShouldBeHandled() {
        let moviesServiceStub = MoviesServiceStub()
        let moviesToReturn: [SearchResponse.Result] = [
            .init(title: "title 1", year: "year 1", imdbID: "imdbID 1", type: .movie, poster: "poster 1"),
            .init(title: "title 2", year: "year 2", imdbID: "imdbID 2", type: .movie, poster: "poster 2")
        ]
        moviesServiceStub.searchMoviesResultToBeReturned = .success(moviesToReturn)
        let sut = ListViewController(
            favoritesManager: FavoritesManagerDummy(),
            moviesService: moviesServiceStub
        )
        _ = sut.view // trick to force load the view
        
        // When
        sut.searchMovieWithTitle("Movie")
        
        // Then
        
        let searchResults = Mirror(reflecting: sut).children.first(where: { $0.label == "searchResults"} )?.value as? [SearchResponse.Result]
        
        XCTAssertEqual(searchResults?.count, 2)
        XCTAssertFalse(sut.tableView.isHidden)
        XCTAssertEqual(sut.searchTextField.text?.isEmpty, true)
    }
    
}

// MARK: - Testing Helpers

final class FavoritesManagerSpy: FavoritesManagerProtocol {
    
    var items: [Favorite] = []
    
    private(set) var loadCalled = false
    func load() {
        loadCalled = true
    }

    private(set) var isMarkedAsFavoriteCalled = false
    private(set) var favoritePassedToIsMarkedAsFavorite: Favorite?
    func isMarkedAsFavorite(_ favorite: Favorite) -> Bool {
        isMarkedAsFavoriteCalled = true
        favoritePassedToIsMarkedAsFavorite = favorite
        return true
    }
    
    private(set) var addCalled = false
    private(set) var favoritePassedToAdd: Favorite?
    @discardableResult
    func add(_ favorite: Favorite) -> Bool {
        addCalled = true
        favoritePassedToAdd = favorite
        return true
    }
    
    private(set) var removeCalled = false
    private(set) var favoritePassedToRemove: Favorite?
    @discardableResult
    func remove(_ favorite: Favorite) -> Bool {
        removeCalled = true
        favoritePassedToRemove = favorite
        return true
    }
    
}

final class MoviesServiceStub: MoviesServiceProtocol {
    
    var searchMoviesResultToBeReturned: Result<[SearchResponse.Result], MoviesServiceError> = .success([])
    func searchMovies(
        withTitle title: String,
        then: @escaping (Result<[SearchResponse.Result], MoviesServiceError>) -> Void
    ) {
        then(searchMoviesResultToBeReturned)
    }
}

final class FavoritesManagerDummy: FavoritesManagerProtocol {
    var items: [Favorite] = []
    func load() {}
    func isMarkedAsFavorite(_ favorite: Favorite) -> Bool { true }
    @discardableResult func add(_ favorite: Favorite) -> Bool { true }
    @discardableResult func remove(_ favorite: Favorite) -> Bool { true }
}

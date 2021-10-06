import XCTest
@testable import SimpleMovies

final class FavoritesViewControllerTests: XCTestCase {
    
    // Using:
    // -> Property-based Injection
    // -> Fakes + Dummies
    func test_when_removeFromFavoriteSucceeds_tableViewShouldChangeNumberOfItems() {
        // Given
        let initialAmountOfItems = 2
        
        let favoritesStoryboard = UIStoryboard(name: "Favorites", bundle: Bundle(for: FavoritesViewController.self))
        guard let sut = favoritesStoryboard
            .instantiateViewController(identifier: "FavoritesViewController") as? FavoritesViewController
        else {
            XCTFail("Could not create SUT.")
            return
        }
        
        let favoritesManagerFake = FavoritesManagerFake()
        favoritesManagerFake.items = buildFakeFavoriteItems(amount: initialAmountOfItems)
        sut.favoritesManager = favoritesManagerFake
        
        AlertHelperFake.runYesAction = true
        sut.alertHelper = AlertHelperFake.self
        
        _ = sut.view // trick to force load the view
        sut.viewWillAppear(true)
        
        let tableViewDummy = UITableView()
        let currentAmountOfItems = sut.tableView(tableViewDummy, numberOfRowsInSection: 0)
        XCTAssertEqual(currentAmountOfItems, initialAmountOfItems)
        
        // When
        sut.tableView(tableViewDummy, didSelectRowAt: IndexPath(row: 0, section: 0))
        
        // Then
        let newAmountOfItems = sut.tableView(tableViewDummy, numberOfRowsInSection: 0)
        XCTAssertEqual(newAmountOfItems, initialAmountOfItems-1)
    }
    
    // MARK: - Helper Functions
    
    private func buildFakeFavoriteItems(amount: Int = 5) -> [Favorite] {
        var items = [Favorite]()
        for i in 0..<amount {
            let newItem = Favorite(
                title: "Movie \(i)",
                year: "\(i)",
                imdbID: "\(i)",
                type: .movie,
                poster: "www.poster.com/\(i)")
            items.append(newItem)
        }
        return items
    }
    
}

// MARK: - Testing Helpers

final class FavoritesManagerFake: FavoritesManagerProtocol {
    
    var items: [Favorite] = [Favorite]()
    
    func load() {}
    
    func isMarkedAsFavorite(_ favorite: Favorite) -> Bool {
        return items.firstIndex(where: { $0.imdbID == favorite.imdbID } ) != nil
    }
    
    @discardableResult
    func add(_ favorite: Favorite) -> Bool {
        items.append(favorite)
        return true
    }
    
    @discardableResult
    func remove(_ favorite: Favorite) -> Bool {
        guard let index = items.firstIndex(where: { $0.imdbID == favorite.imdbID } ) else { return false }
        items.remove(at: index)
        return true
    }
    
}

final class AlertHelperFake: AlertHelperProtocol {
    
    static var runYesAction = true
    static func presentChoiceAlert(
        from controller: UIViewController,
        title: String?,
        message: String,
        yesAction: @escaping () -> Void,
        noAction: (() -> Void)?
    ) {
        if AlertHelperFake.runYesAction {
            yesAction()
        } else {
            noAction?()
        }
    }
    
    static func presentSimpleAlert(
        from controller: UIViewController,
        title: String?,
        message: String
    ) {}
    
}

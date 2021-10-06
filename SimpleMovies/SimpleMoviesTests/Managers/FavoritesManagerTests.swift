import XCTest
@testable import SimpleMovies

final class FavoritesManagerTests: XCTestCase {

    func test_whenAddIsCalledForAValidObject_userDefaultsShouldReceiveValue_andSyncronize() {
        // Given
        let userDefaultsSpy = UserDefaultsSpy()
        let sut = FavoritesManager(
            userDefaults: userDefaultsSpy,
            jsonDecoder: .init(),
            jsonEncoder: .init()
        )
        let mockFavorite = Favorite(
            title: "title",
            year: "year",
            imdbID: "imdbID",
            type: .movie,
            poster: "poster"
        )
        // When
        let addSucceeded = sut.add(mockFavorite)
        // Then
        XCTAssertTrue(addSucceeded)
        XCTAssertTrue(userDefaultsSpy.setValueCalled)
        XCTAssertEqual(1, sut.items.count)
        XCTAssertTrue(userDefaultsSpy.synchronizeCalled)
    }

}

// MARK: - Testing Helpers
final class UserDefaultsSpy: UserDefaults {
    
    private(set) var setValueCalled = false
    private(set) var setValuePassed: Any?
    private(set) var setValueKeyPassed: String?
    
    override func set(_ value: Any?, forKey defaultName: String) {
        setValueCalled = true
        setValuePassed = value
        setValueKeyPassed = defaultName
    }
    
    private(set) var synchronizeCalled = false
    override func synchronize() -> Bool {
        synchronizeCalled = true
        return true
    }
    
}

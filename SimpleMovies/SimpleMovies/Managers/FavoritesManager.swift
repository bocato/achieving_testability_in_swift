import Foundation

typealias Favorite = SearchResponse.Result

protocol FavoritesManagerProtocol {
    var items: [Favorite] { get }
    func load()
    func isMarkedAsFavorite(_ favorite: Favorite) -> Bool
    @discardableResult func add(_ favorite: Favorite) -> Bool
    @discardableResult func remove(_ favorite: Favorite) -> Bool
}

final class FavoritesManager: FavoritesManagerProtocol {
    
    // MARK: - Singleton
    
    static let shared: FavoritesManager = {
        return FavoritesManager(
            userDefaults: .standard,
            jsonDecoder: .init(),
            jsonEncoder: .init()
        )
    }()
    
    // MARK: - Dependencies
    
    private var userDefaults: UserDefaults
    private var jsonDecoder: JSONDecoder
    private var jsonEncoder: JSONEncoder
    
    // MARK: - Initialization
    
    init(
        userDefaults: UserDefaults,
        jsonDecoder: JSONDecoder,
        jsonEncoder: JSONEncoder
    ) {
        self.userDefaults = userDefaults
        self.jsonDecoder = jsonDecoder
        self.jsonEncoder = jsonEncoder
    }
    
    // MARK: - Properties
    
    private(set) var items = [Favorite]()
    
    // MARK: - Public Methods
    
    func load() {
        guard
            let data = userDefaults.value(forKey: Constants.favoritesKey) as? Data,
            let decodedData = try? jsonDecoder.decode([Favorite].self, from: data)
        else { return }
        items = decodedData
    }
    
    func isMarkedAsFavorite(_ favorite: Favorite) -> Bool {
        return items.firstIndex(where: { $0.imdbID == favorite.imdbID } ) != nil
    }
    
    @discardableResult
    func add(_ favorite: Favorite) -> Bool {
        var newItems = items
        newItems.append(favorite)
        return syncronize(with: newItems)
    }
    
    @discardableResult
    func remove(_ favorite: Favorite) -> Bool {
        guard let index = items.firstIndex(where: { $0.imdbID == favorite.imdbID } ) else { return false }
        var newItems = items
        newItems.remove(at: index)
        return syncronize(with: newItems)
    }
    
    // MARK: - Private Properties
    private func syncronize(with newItems: [Favorite]) -> Bool {
        guard let encodedData = try? jsonEncoder.encode(newItems) else { return false }
        userDefaults.set(encodedData, forKey: Constants.favoritesKey)
        let sincronizationSucceeded = userDefaults.synchronize()
        if sincronizationSucceeded {
            self.items = newItems
        }
        return sincronizationSucceeded
    }
    
}

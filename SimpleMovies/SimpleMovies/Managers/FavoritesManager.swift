import Foundation

typealias Favorite = SearchResponse.Result

final class FavoritesManager {
    
    // MARK: - Singleton
    
    static let shared = FavoritesManager()
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Properties
    
    private(set) var items = [Favorite]()
    
    // MARK: - Public Methods
    
    func load() {
        let defaults = UserDefaults.standard
        guard
            let data = defaults.value(forKey: Constants.favoritesKey) as? Data,
            let decodedData = try? JSONDecoder().decode([Favorite].self, from: data)
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
        guard let encodedData = try? JSONEncoder().encode(newItems) else { return false }
        UserDefaults.standard.set(encodedData, forKey: Constants.favoritesKey)
        UserDefaults.standard.synchronize()
        self.items = newItems
        return true
    }
    
}

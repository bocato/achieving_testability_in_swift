import Foundation
import UIKit

struct Pokemon {
    let id: String
    let name: String
}

protocol PokemonsServiceProtocol {
    func loadPokemons(
        for userID: String,
        then completion: @escaping (Result<[Pokemon], Error>) -> Void
    )
}

final class PokemonsService: PokemonsServiceProtocol {
    func loadPokemons(
        for userID: String,
        then completion: @escaping (Result<[Pokemon], Error>) -> Void
    ) { /* ... */ }
}

protocol TradingManagerProtocol {
    func exchange(
        myPokemon: Pokemon,
        for otherPokemon: Pokemon,
        with userID: String,
        then completion: @escaping (Result<Void, Error>) -> Void
    )
}

final class TradingManager: TradingManagerProtocol {
    func exchange(
        myPokemon: Pokemon,
        for otherPokemon: Pokemon,
        with userID: String,
        then completion: @escaping (Result<Void, Error>) -> Void
    ) { /* ... */ }
}

final class DependencyContainer {
    private var pokemonsService: PokemonsServiceProtocol
    private var tradingManager: TradingManagerProtocol
    
    private static var sharedInstance: DependencyContainer?
    static var shared: DependencyContainer {
        guard let instance = sharedInstance else { fatalError("You should call `initialize` once!") }
        return instance
    }
    
    private init(
        pokemonsService: PokemonsServiceProtocol, tradingManager: TradingManagerProtocol
    ) {
        self.pokemonsService = pokemonsService
        self.tradingManager = tradingManager
    }
    
    static func initialize(
        pokemonsService: PokemonsServiceProtocol = PokemonsService(),
        tradingManager: TradingManagerProtocol = TradingManager()
    ) { // called from app delegate, for example.
        Self.sharedInstance = .init(pokemonsService: pokemonsService,tradingManager: tradingManager)
    }
}

protocol ViewControllerFactoryProtocol {
    func makePokemonTradeViewController(for pokemonIWant: Pokemon, userToTradeWithID: String) -> UIViewController
}

protocol ServiceFactoryProtocol {
    func makePokemonsService() ->  PokemonsServiceProtocol
}

extension DependencyContainer: ViewControllerFactoryProtocol {
    func makePokemonTradeViewController(for pokemonIWant: Pokemon, userToTradeWithID: String) -> UIViewController {
        PokemonTradeViewController(
            pokemonIWant: pokemonIWant,
            userToTradeWithID: userToTradeWithID,
            tradingManager: tradingManager,
            pokemonsService: pokemonsService
        )
    }
}
extension DependencyContainer: ServiceFactoryProtocol {
    func makePokemonsService() -> PokemonsServiceProtocol { pokemonsService }
}

final class PokemonListViewController: UITableViewController {
    // MARK: - Dependencies
    typealias DependencyFactory = ViewControllerFactoryProtocol & ServiceFactoryProtocol
    private let dependencyFactory: DependencyFactory
    private let userToTradeWithID: String
    private lazy var pokemonsService: PokemonsServiceProtocol = dependencyFactory.makePokemonsService()
    
    // MARK: - Properties
    
    private var pokemons: [Pokemon] = []
    
    // MARK: - Initialization

    init(
        dependencyFactory: DependencyFactory = DependencyContainer.shared,
        userToTradeWithID: String
    ) {
        self.dependencyFactory = dependencyFactory
        self.userToTradeWithID = userToTradeWithID
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: - Lifecycle

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pokemonsService.loadPokemons(for: userToTradeWithID) { [weak self] result in
            do {
                let pokemons = try result.get()
                self?.reloadTableView(with: pokemons)
            } catch { print(error) }
        }
    }
}

extension PokemonListViewController {
    // MARK: - Private API
    
    private func reloadTableView(with pokemons: [Pokemon]) { /* ... */ }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pokemonIWant = pokemons[indexPath.row]
        let tradeViewController = dependencyFactory.makePokemonTradeViewController(
            for: pokemonIWant,
            userToTradeWithID: userToTradeWithID
        )
        navigationController?.pushViewController(tradeViewController, animated: true)
    }
}


final class PokemonTradeViewController: UIViewController {
    // MARK: - Dependencies
    
    private let pokemonIWant: Pokemon
    private let userToTradeWithID: String
    private let tradingManager: TradingManagerProtocol
    private let pokemonsService: PokemonsServiceProtocol
    
    // MARK: - Initialization

    init(
        pokemonIWant: Pokemon,
        userToTradeWithID: String,
        tradingManager: TradingManagerProtocol,
        pokemonsService: PokemonsServiceProtocol
    ) {
        self.pokemonIWant = pokemonIWant
        self.userToTradeWithID = userToTradeWithID
        self.tradingManager = tradingManager
        self.pokemonsService = pokemonsService
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: - Lifecycle

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

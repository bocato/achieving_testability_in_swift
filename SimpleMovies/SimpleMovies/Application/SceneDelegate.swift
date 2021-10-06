import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        setupInitialController(windowScene)
    }
    
    private func setupInitialController(_ windowScene: UIWindowScene) {
        let rootViewController = createTabBar()
        let frame = windowScene.coordinateSpace.bounds
        window = UIWindow(frame: frame)
        window?.windowScene = windowScene
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
    }
    
    private func createTabBar() -> UITabBarController {
        
        let listViewController = ListViewController()
        listViewController.title = "Search"
        listViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 0)
        
        let favoritesStoryboard = UIStoryboard(name: "Favorites", bundle: Bundle(for: FavoritesViewController.self))
        let favoritesViewControler = favoritesStoryboard.instantiateViewController(identifier: "FavoritesViewController")
        favoritesViewControler.title = "Favorites"
        favoritesViewControler.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 1)
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [
            UINavigationController(rootViewController: listViewController),
            UINavigationController(rootViewController: favoritesViewControler)
        ]
        
        return tabBarController
    }

}


import UIKit

class FavoritesViewController: UIViewController {

    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Dependencies
    
    var favoritesManager: FavoritesManagerProtocol = FavoritesManager.shared
    var alertHelper: AlertHelperProtocol.Type = AlertHelper.self
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    // MARK: - Setup
    
    private func loadData() {
        tableView.reloadData()
        tableView.isHidden = favoritesManager.items.count == 0
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isHidden = true
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = 200
    }
    
}
extension FavoritesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoritesManager.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteTableViewCell", for: indexPath) as? FavoriteTableViewCell else { return UITableViewCell() }
        
        let searchResult = favoritesManager.items[indexPath.row]
        let viewData = ListItemViewData(
            searchResult: searchResult,
            isFavorite: true
        )
        
        cell.setup(with: viewData)
        
        return cell
        
    }
    
}
extension FavoritesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFavorite = favoritesManager.items[indexPath.row]
        alertHelper.presentChoiceAlert(
            from: self,
            message: "Remove from favorites?",
            yesAction: { [tableView, favoritesManager] in
                favoritesManager.remove(selectedFavorite)
                tableView.reloadData()
            }
        )
    }
    
}

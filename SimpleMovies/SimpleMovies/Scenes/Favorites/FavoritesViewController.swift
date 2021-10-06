import UIKit

class FavoritesViewController: UIViewController {

    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
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
        tableView.isHidden = FavoritesManager.shared.items.count == 0
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
        return FavoritesManager.shared.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteTableViewCell", for: indexPath) as? FavoriteTableViewCell else { return UITableViewCell() }
        
        let searchResult = FavoritesManager.shared.items[indexPath.row]
        let viewData = buildViewData(
            from: searchResult
        )
        
        cell.setup(with: viewData)
        
        return cell
        
    }
    
    private func buildViewData(
        from searchResult: SearchResponse.Result
    ) -> ListItemViewData {
        let isFavorite = FavoritesManager.shared.isMarkedAsFavorite(searchResult)
        return ListItemViewData(
            searchResult: searchResult,
            isFavorite: isFavorite
        )
    }

}
extension FavoritesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFavorite = FavoritesManager.shared.items[indexPath.row]
        AlertHelper.presentChoiceAlert(
            from: self,
            message: "Remove from favorites?",
            yesAction: { [tableView] in
                FavoritesManager.shared.remove(selectedFavorite)
                tableView.reloadData()
            }
        )
    }
    
}

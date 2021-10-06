import UIKit

class ListViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    private var searchResults = [SearchResponse.Result]()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - Setup
    
    private func setup() {
        setupTableView()
        FavoritesManager.shared.load()
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.isHidden = true
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = 200
        tableView.register(
            UINib(nibName: "ListTableViewCell", bundle: Bundle(for: ListTableViewCell.self)),
            forCellReuseIdentifier: "ListTableViewCell"
        )
    }
    
    // MARK: - IBActions
    
    @IBAction func didTapSearchButton(_ sender: Any) {
        guard let text = searchTextField.text, !text.isEmpty else {
            AlertHelper.presentSimpleAlert(
                from: self,
                message: "Empty search field!"
            )
            return
        }
        searchMovieWithTitle(text)
    }
    
    // MARK: - Search Logic
    
    func searchMovieWithTitle(_ title: String) {
        
        let service = MoviesService()
        
        service.searchMovies(withTitle: title) { [unowned self] result in
            switch result {
            case let .success(moviesFromSearch):
                self.handleMoviesSearchSuccess(moviesFromSearch)
            case let .failure(serviceError):
                self.handleMoviesServiceError(serviceError)
            }
        }
        
    }
    
    private func handleMoviesSearchSuccess(_ results: [SearchResponse.Result]) {
        searchResults = results
        tableView.reloadData()
        tableView.isHidden = searchResults.count == 0
        searchTextField.text = ""
    }
    
    private func handleMoviesServiceError(_ error: MoviesServiceError) {
        switch error {
        case let .api(apiError):
            AlertHelper.presentSimpleAlert(
                from: self,
                title: "API Error",
                message: apiError.error
            )
        default:
            AlertHelper.presentSimpleAlert(
                from: self,
                title: "Error",
                message: "Something is wrong.\nTry again :)"
            )
        }
    }
    
    
}
extension ListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListTableViewCell", for: indexPath) as? ListTableViewCell else { return UITableViewCell() }
        
        let searchResult = searchResults[indexPath.row]
        let viewData = buildViewData(
            from: searchResult
        )
        
        cell.setup(
            with: viewData,
            onAddFavoriteTapped: { FavoritesManager.shared.add(searchResult) },
            onRemoveFavoriteTapped: { FavoritesManager.shared.remove(searchResult) }
        )
        
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

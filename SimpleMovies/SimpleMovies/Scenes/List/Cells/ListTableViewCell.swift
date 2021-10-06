import UIKit

struct ListItemViewData {
    let title: String
    let year: String
    let poster: String
    var isFavorite: Bool
}
extension ListItemViewData {
    init(
        searchResult: SearchResponse.Result,
        isFavorite: Bool
    ) {
        self.title = searchResult.title
        self.year = searchResult.year
        self.poster = searchResult.poster
        self.isFavorite = isFavorite
    }
}

class ListTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var movieDescriptionLabel: UILabel!
    
    // MARK: - Properties
    
    private var imageLoadTask: URLSessionDataTask?
    private var viewData: ListItemViewData?
    private var onAddFavoriteTapped: (() -> (Bool))?
    private var onRemoveFavoriteTapped: (() -> (Bool))?
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.image = nil
        movieDescriptionLabel.text = nil
        favoriteButton.isSelected = false
        favoriteButton.setImage(.blackStar, for: .normal)
        imageLoadTask?.cancel()
    }
    
    // MARK: - Setup

    func setup(
        with viewData: ListItemViewData,
        onAddFavoriteTapped: @escaping () -> (Bool),
        onRemoveFavoriteTapped: @escaping () -> (Bool)
    ) {
        self.viewData = viewData
        self.onAddFavoriteTapped = onAddFavoriteTapped
        self.onRemoveFavoriteTapped = onRemoveFavoriteTapped
        setupImageView(with: viewData.poster)
        setupDescriptionLabel(with: viewData)
        setFavoriteButtonValue(viewData.isFavorite)
    }
    
    private func setupImageView(with poster: String) {
        posterImageView.contentMode = .scaleAspectFit
        imageLoadTask = posterImageView.setImageFromURL(poster)
    }
    
    private func setupDescriptionLabel(with data: ListItemViewData) {
        
        let boldAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 14)]
        
        let descriptionAttributedText = NSMutableAttributedString(
            string: "(",
            attributes: boldAttributes
        )
        
        descriptionAttributedText.append(.init(string: data.year, attributes: boldAttributes))
        descriptionAttributedText.append(.init(string: ")\n", attributes: boldAttributes))
        descriptionAttributedText.append(
            .init(
                string: data.title,
                attributes: [.font: UIFont.systemFont(ofSize: 14)]
            )
        )
        
        movieDescriptionLabel.attributedText = descriptionAttributedText
        
    }
    
    private func setFavoriteButtonValue(_ isFavorite: Bool) {
        viewData?.isFavorite = isFavorite
        let image: UIImage? = isFavorite ? .yellowStar : .blackStar
        favoriteButton.setImage(image, for: .normal)
    }
    
    // MARK: - Actions
    
    @IBAction func didTapFavoriteButton(_ sender: UIButton) {
        if viewData?.isFavorite == true {
            removeFromFavorites()
        } else {
            addToFavorites()
        }
    }
    
    // MARK: - Private Functions
    
    private func removeFromFavorites() {
        let deletionSucceeded = onRemoveFavoriteTapped?()
        if deletionSucceeded == true {
            setFavoriteButtonValue(false)
        }
    }
    
    private func addToFavorites() {
        let additionSucceeded = onAddFavoriteTapped?()
        if additionSucceeded == true {
            setFavoriteButtonValue(true)
        }
    }
    
}

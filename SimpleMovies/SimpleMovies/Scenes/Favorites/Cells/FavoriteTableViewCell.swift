import UIKit

class FavoriteTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var movieDescriptionLabel: UILabel!
    
    // MARK: - Properties
    
    var imageLoadTask: URLSessionDataTask?
    private var viewData: ListItemViewData?
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.image = nil
        movieDescriptionLabel.text = nil
        imageLoadTask?.cancel()
    }
    
    // MARK: - Setup

    func setup(with viewData: ListItemViewData) {
        self.viewData = viewData
        setupImageView(with: viewData.poster)
        setupDescriptionLabel(with: viewData)
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
    
}

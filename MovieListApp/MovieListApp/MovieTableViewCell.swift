import UIKit

class MovieTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var studioLabel: UILabel!
    @IBOutlet weak var criticsRatingLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    func configure(with movie: Movie) {
        titleLabel.text = movie.title
        studioLabel.text = movie.studio
        criticsRatingLabel.text = "Rating: \(movie.criticsRating)"
    }
}

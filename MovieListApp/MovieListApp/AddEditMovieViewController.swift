import UIKit
import CoreData

protocol AddEditMovieViewControllerDelegate: AnyObject {
    func didSaveMovie()
}

class AddEditMovieViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var studioTextField: UITextField!
    @IBOutlet weak var criticsRatingTextField: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var studioLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    var movie: Movie?
    weak var delegate: AddEditMovieViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let movie = movie {
            titleTextField.text = movie.title
            studioTextField.text = movie.studio
            criticsRatingTextField.text = "\(movie.criticsRating)"
            // Set other fields as needed
        }
    }

    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        let context = CoreDataStack.shared.context
        if movie == nil {
            movie = Movie(context: context)
        }
        movie?.title = titleTextField.text
        movie?.studio = studioTextField.text
        movie?.criticsRating = Double(criticsRatingTextField.text ?? "") ?? 0.0
        // Set other fields as needed

        do {
            try context.save()
            delegate?.didSaveMovie()
            navigationController?.popViewController(animated: true)
        } catch {
            print("Failed to save movie: \(error)")
        }
    }
}

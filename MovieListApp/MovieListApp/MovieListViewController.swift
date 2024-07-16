import UIKit
import CoreData

class MovieListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AddEditMovieViewControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    var movies: [Movie] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preloadMovies()
        fetchMovies()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 150 // Set the row height to 150
        tableView.estimatedRowHeight = 150 // Set the estimated row height to 150
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addMovie))
        
    }
    
    func preloadMovies() {
        let context = CoreDataStack.shared.context
        
        guard let path = Bundle.main.path(forResource: "favouritemovies", ofType: "json") else {
            print("JSON file not found")
            return
        }
        
        let url = URL(fileURLWithPath: path)
        
        do {
            let data = try Data(contentsOf: url)
            let movies = try JSONDecoder().decode([MovieData].self, from: data)
            
            // Check if data is already loaded to prevent duplicates
            let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
            let count = try context.count(for: fetchRequest)
            
            if count == 0 {
                for movieData in movies {
                    let movie = Movie(context: context)
                    movie.movieID = Int32(movieData.movieID)
                    movie.title = movieData.title
                    movie.studio = movieData.studio
                    movie.criticsRating = movieData.criticsRating
                    movie.actors = movieData.actors
                    movie.directors = movieData.directors
                    movie.genres = movieData.genres
                    movie.length = Int16(movieData.length)
                    movie.mpaRating = movieData.mpaRating
                    movie.shortdescription = movieData.shortDescription
                    movie.year = Int16(movieData.year)
                }
                try context.save()
            }
        } catch {
            print("Failed to load and save movies: \(error)")
        }
    }
    
    func fetchMovies() {
        let context = CoreDataStack.shared.context
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        
        do {
            movies = try context.fetch(fetchRequest)
            print("Fetched movies count: \(movies.count)")  // Debugging line
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            print("Failed to fetch movies: \(error)")
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Number of rows: \(movies.count)")  // Debugging line
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieTableViewCell", for: indexPath) as! MovieTableViewCell
        let movie = movies[indexPath.row]
        cell.configure(with: movie)
        print("Configuring cell for movie: \(movie.title ?? "")")  // Debugging line
        return cell
    }
    
    @objc func addMovie() {
        performSegue(withIdentifier: "AddEditMovieSegue", sender: nil)
    }
    // MARK: - Navigation

        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "AddEditMovieSegue",
               let destination = segue.destination as? AddEditMovieViewController {
                if let indexPath = tableView.indexPathForSelectedRow {
                    let movie = movies[indexPath.row]
                    destination.movie = movie
                }
            }
        }

        /// MARK: - Delete Movie
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = CoreDataStack.shared.context
            context.delete(movies[indexPath.row])
            do {
                try context.save()
                movies.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                print("Failed to delete movie: \(error)")
            }
        }
    }
    // MARK: - AddEditMovieViewControllerDelegate

        func didSaveMovie() {
            fetchMovies()
        }
    }
    
    struct MovieData: Codable {
        let movieID: Int
        let title: String
        let studio: String
        let criticsRating: Double
        let actors: String
        let directors: String
        let genres: String
        let length: Int
        let mpaRating: String
        let shortDescription: String
        let year: Int
    }


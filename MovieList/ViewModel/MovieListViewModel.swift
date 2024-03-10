import Foundation
import Firebase
import FirebaseFirestoreSwift


// TODO: add pagination
@MainActor
class MovieListViewModel : ObservableObject {
    @Published var movies: [Movie] = []
    @Published var searchText: String  = ""
    private let db = Firestore.firestore()
    
    init(){
        Task{
            try await getAllMovies()
        }
    }
    
    var filteredMovies: [Movie]{
        if(searchText == ""){
            return self.movies;
        }else{
            return movies.filter{
                movie in movie.name.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    func getAllMovies() async throws {
        Task{
            movies = try await MovieConnector.shared.getAllMovies()
        }
    }
}

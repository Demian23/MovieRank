import Foundation

// TODO: add pagination
@MainActor
class MovieListViewModel : ObservableObject {
    @Published var movies: [Movie] = []
    @Published var searchText: String  = ""
    
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
        movies = try await MovieConnector.getAllMovies()
    }
    
}

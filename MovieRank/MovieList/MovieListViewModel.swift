import Foundation

// TODO: add pagination

public class MovieListViewModel : ObservableObject {
    // it's better to use dictionary here
    @Published var movies: [Movie] = []
    @Published var searchText: String  = ""
    
    init(){
        Task{
            try await getAllMovies()
        }
    }
    
    func fetchDetailData(for movieId: String, from uid: String, completion: @escaping (String, Bool)->Void) {
        Task{
            let isFavouriteMovie = try await FavouritesConnector.isFavourites(movieId: movieId, for: uid)
            let mark = try await MovieConnector.fetchUserMarkForMovie(movieId: movieId, currentUserId: uid)
            completion(mark, isFavouriteMovie)
        }
    }
   
    @MainActor
    func onMarkUpdate(for movieId: String, from uid: String, mark: String, completion: (Movie)->Void) async throws {
        try await MovieConnector.updateOrCreateNewMarkForMovie(movieId: movieId, currentUserId: uid, newMark: mark)
        guard let movie = try await MovieConnector.getMovie(by: movieId) else {return}
        completion(movie)
    }
    
    func localUpdate(newMovie: Movie){
        guard let index = movies.firstIndex(where: {movie in movie.id == newMovie.id}) else {return}
        movies[index] = newMovie
    }
    
    func onFavouritesChange(for movieId: String, from uid: String, isFavourite: Bool) async throws {
        if isFavourite {
            try await FavouritesConnector.addMovieForUser(movieId: movieId, for: uid)
        } else {
            try await FavouritesConnector.deleteMovieForUser(movieId: movieId, for: uid)
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
    
    @MainActor
    func getAllMovies() async throws {
        movies = try await MovieConnector.getAllMovies()
    }
    
}

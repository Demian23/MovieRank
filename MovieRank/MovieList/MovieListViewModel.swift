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
    
    func fetchDetailData(for movieId: String, from uid: String, completion: @escaping (String, Bool)->Void) {
        Task{
            let isFavouriteMovie = try await FavouritesConnector.isFavourites(movieId: movieId, for: uid)
            let mark = try await MovieConnector.fetchUserMarkForMovie(movieId: movieId, currentUserId: uid)
            completion(mark, isFavouriteMovie)
        }
    }
    
    func onMarkUpdate(for movieId: String, from uid: String, mark: String) async throws {
        try await MovieConnector.updateOrCreateNewMarkForMovie(movieId: movieId, currentUserId: uid, newMark: mark)
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
    
    func getAllMovies() async throws {
        movies = try await MovieConnector.getAllMovies()
    }
    
}

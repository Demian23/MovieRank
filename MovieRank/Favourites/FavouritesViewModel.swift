import Foundation
import SwiftUI
import Firebase

public class FavouritesViewModel : ObservableObject {
    private var favouritesListener: ListenerRegistration? = nil
    
    @Published var searchText: String  = ""
    // TODO: array should be thread safe
    @Published var movies: [Movie] = []//TSArray<Movie> = TSArray<Movie>()
    @Published var isFetched = false
    
    @MainActor
    func fetchFavouritesWithLookUp(userId uid: String, with moviesVM: MovieListViewModel) {
        handleRealtimeChangesInFavourites(uid: uid, movieListVM: moviesVM)
    }
    
    deinit{
        favouritesListener?.remove()
    }
    
        
    var filteredMovies: [Movie] {
        if searchText.isEmpty {
            return self.movies
        } else{
            return self.filteredMovies.filter {
                movie in movie.name.lowercased().contains(self.searchText.lowercased())
            }
        }
    }
}


// MARK: logic
public extension FavouritesViewModel{
    
    func clearCurrentState() {
        favouritesListener?.remove()
        movies.removeAll()
        favouritesListener = nil
    }
    
    func localUpdate(newMovie: Movie){
        guard let index = movies.firstIndex(where: {movie in movie.id == newMovie.id}) else {return}
        let favProp = newMovie.favouritesProperties ?? movies[index].favouritesProperties!
        movies[index] = newMovie
        movies[index].favouritesProperties = favProp
    }
    
    @MainActor
    func handleRealtimeChangesInFavourites(uid: String, movieListVM: MovieListViewModel) {
        // TODO: when logout detach too
        let currentFavouritesRef = FavouritesConnector.favouritesCollectionRefForUser(for: uid)
        if favouritesListener == nil {
            favouritesListener = currentFavouritesRef.addSnapshotListener {querySnapshot, error in
                // throw pointless, cause where we will handle it?
                if let error = error {
                    print("Error occured: \(error.localizedDescription)")
                    return
                }
                guard let snapshot = querySnapshot else {
                    print("Can't fetch snapshot with realtime changes.")
                    return
                }
                
                snapshot.documentChanges.forEach{diff in
                    if diff.type == .added {
                        // listen on appending in array too and append empty structure, fill it in Task with data from db?
                        let movieId = diff.document.documentID
                        // TODO: need incapsulation
                        let favProp = try! diff.document.data(as: FavouritesProperties.self)
                        if let index = movieListVM.movies.firstIndex(where: {movie in movie.id == movieId}){
                            var movie = movieListVM.movies[index]
                            movie.favouritesProperties = favProp
                            self.movies.append(movie)
                        } else {
                            Task {
                                guard var movie = try await MovieConnector.getMovie(by: movieId) else {return}
                                movie.favouritesProperties = favProp
                                self.movies.append(movie)
                            }
                        }
                    }
                    if diff.type == .modified {
                        let movieId = diff.document.documentID
                        let favProp = try! diff.document.data(as: FavouritesProperties.self)
                        if let index = self.movies.firstIndex(where: {favMovie in favMovie.id == movieId}) {
                            self.movies[index].favouritesProperties = favProp
                        } else {
                            Task {
                                guard var movie = try await MovieConnector.getMovie(by: movieId) else {return}
                                movie.favouritesProperties = favProp
                                self.movies.append(movie)
                            }
                        }
                    }
                    if diff.type == .removed {
                        let movieId = diff.document.documentID
                        if let index = self.movies.firstIndex(where: {favMovie in favMovie.id == movieId}) {
                            self.movies.remove(at: index)
                        }
                    }
                }
            }
        }
    }
}

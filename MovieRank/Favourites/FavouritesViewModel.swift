import Foundation
import SwiftUI
import Firebase

@MainActor
public class FavouritesViewModel : ObservableObject {
    private var favouritesListener: ListenerRegistration? = nil
    public var isListening: Bool {favouritesListener != nil}
    
    @Published var searchText: String  = ""
    @EnvironmentObject var authModel: AuthViewModel
    @EnvironmentObject var movieListModel: MovieListViewModel
    
    @Published var movies: TSArray<Movie> = TSArray<Movie>()
    
    init() {
        Task{
            try await getAllFavourites()
        }
        handleRealtimeChangesInFavourites()
    }
    
    deinit{
        favouritesListener?.remove()
    }
    
        
    var filteredMovies: [Movie] {
        if searchText.isEmpty {
            return movies.arrayCopy();
        } else{
            return movies.arrayCopy().filter {
                movie in movie.name.lowercased().contains(searchText.lowercased())
            }
        }
    }
        
}


// MARK: logic
public extension FavouritesViewModel{
    
    private func getAllFavourites() async throws {
        movies += try await FavouritesConnector.getAllForUserWithLocalLookup(for:authModel.uid!, localMovies: movieListModel.movies)
    }
    
    func clearCurrentState() {
        favouritesListener?.remove()
        movies.removeAll()
        favouritesListener = nil
    }
    
    func handleRealtimeChangesInFavourites() {
        // TODO: when logout detach too
        let currentFavouritesRef = FavouritesConnector.favouritesCollectionRefForUser(for: authModel.uid!)
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
                        Task {
                            guard var movie = try await MovieConnector.getMovie(by: movieId) else {return}
                            movie.favouritesProperties = favProp
                            self.movies.append(movie)
                        }
                    }
                    if diff.type == .modified {
                        let movieId = diff.document.documentID
                        let favProp = try! diff.document.data(as: FavouritesProperties.self)
                        if let index = self.movies.index(where: {favMovie in favMovie.id == movieId}) {
                            self.movies[index]!.favouritesProperties = favProp
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
                        if let index = self.movies.index(where: {favMovie in favMovie.id == movieId}) {
                            self.movies.remove(at: index)
                        }
                    }
                }
            }
        }
    }
}

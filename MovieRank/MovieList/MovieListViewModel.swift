import Foundation
import PhotosUI

public class MovieListViewModel: ObservableObject {
    // it's better to use dictionary here
    @Published var movies: [Movie] = []
    @Published var images: [String: [UIImage]] = [:]
    @Published var searchText: String = ""

    init() {
        Task {
            try await getAllMovies()
        }
    }

    func fetchDetailData(
        for movieId: String, from uid: String, completion: @escaping (String, FavouritesProperties?) -> Void,
        imagesCallback: @escaping (UIImage) -> Void
    ) {
        if let movieImages = images[movieId] {
            for uiImage in movieImages {
                imagesCallback(uiImage)
            }
        } else {
            Task {
                await MovieStorageConnector.downloadImages(
                    for: movieId,
                    completion: { uiImage in
                        if self.images[movieId] != nil {
                            self.images[movieId]! += [uiImage]
                        } else {
                            self.images[movieId] = [uiImage]
                        }
                        imagesCallback(uiImage)
                    })
            }
        }
        Task {
            let propOptional = try await FavouritesConnector.getProperties(
                movieId: movieId, for: uid)
            let mark = try await MovieConnector.fetchUserMarkForMovie(
                movieId: movieId, currentUserId: uid)
            completion(mark, propOptional)
        }
    }

    @MainActor
    func onMarkUpdate(
        for movieId: String, from uid: String, mark: String, completion: (Movie) -> Void
    ) async throws {
        try await MovieConnector.updateOrCreateNewMarkForMovie(
            movieId: movieId, currentUserId: uid, newMark: mark)
        guard let movie = try await MovieConnector.getMovie(by: movieId) else { return }
        completion(movie)
    }

    func localUpdate(newMovie: Movie) {
        guard let index = movies.firstIndex(where: { movie in movie.id == newMovie.id }) else {
            return
        }
        movies[index] = newMovie
    }

    func onFavouritesChange(
        for movieId: String, from uid: String, prevState: FavouritesPurpose, properties: FavouritesProperties
    ) async throws
        -> FavouritesPurpose {
            if prevState == properties.purpose {
                try await FavouritesConnector.deleteMovieForUser(movieId: movieId, for: uid)
                return .none
            }
            switch prevState {
            case .none:
                try await FavouritesConnector.addMovieForUser(movieId: movieId, for: uid, movieProperties: properties)
                return properties.purpose
            case .WatchLater, .Favourite:
                try await FavouritesConnector.updateMoviePurpose(movieId: movieId, for: uid, purpose: properties.purpose)
                return properties.purpose
            }
    }

    var filteredMovies: [Movie] {
        if searchText == "" {
            return self.movies
        } else {
            return movies.filter {
                movie in movie.name.lowercased().contains(searchText.lowercased())
            }
        }
    }

    @MainActor
    func getAllMovies() async throws {
        movies = try await MovieConnector.getAllMovies()
    }
}

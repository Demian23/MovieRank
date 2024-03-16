import Foundation

@MainActor
final class NewMovieViewModel{
    static let shared = NewMovieViewModel()
    private init(){}
    func addNewMovie(movie: Movie, by uid: String)async throws {
        try await MovieConnector.addNewMovie(newMovie: movie, currentUserId: uid);
        try await UserConnector.changeUserScore(userId: uid, on: 1)
    }
    
}

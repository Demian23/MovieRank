import Foundation
import Firebase
final class FavouritesConnector {
    private static let favourites = "favourites"
    private static let favouritesForUser = "userMovies"
    private static let favouritesPurposeKey = "purpose"
    private static var db = Firestore.firestore()
    private init(){}
    
    static func favouritesCollectionRefForUser(for uid: String) -> CollectionReference {
        return db.collection(favourites).document(uid).collection(favouritesForUser)
    }
    
    static func addMovieForUser(movieId id: String, for uid: String, movieProperties prop: FavouritesProperties? = nil) async throws {
        let to = FavouritesConnector.favouritesCollectionRefForUser(for: uid).document(id);
        let data = prop ?? FavouritesProperties.init(purpose: FavouritesPurpose.Favourite)
        let encodedData = try Firestore.Encoder().encode(data)
        try await to.setData(encodedData)
    }
    
    static func deleteMovieForUser(movieId id: String, for uid: String) async throws{
        let to = FavouritesConnector.favouritesCollectionRefForUser(for: uid).document(id);
        try await to.delete()
    }
    
    static func isFavourites(movieId id: String, for uid: String) async throws -> Bool {
        let doc = try await favouritesCollectionRefForUser(for: uid).document(id).getDocument()
        if doc.exists {
            return true
        } else {
            return false
        }
    }
    
    static func getProperties(movieId id: String, for uid: String) async throws -> FavouritesProperties?{
        return try await favouritesCollectionRefForUser(for: uid).document(id).getDocument(as: FavouritesProperties?.self)
    }
    
    static func getAllForUserWithLocalLookup(for uid: String, localMovies movies: [Movie]) async throws -> [Movie] {
        var result : [Movie] = []
        let from = FavouritesConnector.favouritesCollectionRefForUser(for: uid)
        let snapshot = try await from.getDocuments()
        for document in snapshot.documents {
            let favouritesProperties = try document.data(as: FavouritesProperties.self)
            var movieForAppend: Movie
            let movieId = document.documentID
            if let index = movies.firstIndex(where: {movie in movie.id == movieId}){
                movieForAppend = movies[index]
            } else {
                // if no movie -> database in not consistent condition
                guard let fetchedMovie = try await MovieConnector.getMovie(by: movieId) else {continue}
                movieForAppend = fetchedMovie
            }
            movieForAppend.favouritesProperties = favouritesProperties
            result.append(movieForAppend)
        }
        return result
    }
}

import Foundation
import Firebase
import FirebaseFirestore
@MainActor
class MovieConnector{
    static private let movies = "movies"
    static private let movieMarkComponents = ["marksWholeScore", "marksAmount"]
    static private let marks = ["marks", "user"]
    static private let userMarkKey = "userMark"
    static private var db = Firestore.firestore()
    
    static let shared = MovieConnector()
    
    private init(){}
    
    static func movieDocumentRef(for id: String) -> DocumentReference {
        return db.collection(movies).document(id)
    }
    static func markDocumentRef(for movieId: String, from userId: String) -> DocumentReference {
        return db.collection(marks[0]).document(movieId).collection(marks[1]).document(userId)
    }
    
    static func addNewMovie(newMovie movie: Movie, currentUserId uid: String) async throws {
        let batch = db.batch()
        
        let encodedMovie = try Firestore.Encoder().encode(movie)
        
        let newMovieRef = movieDocumentRef(for: movie.id);
        batch.setData(encodedMovie, forDocument: newMovieRef)
        
        if movie.marksAmount > 0{
            batch.setData([userMarkKey: String(movie.marksWholeScore)], forDocument: markDocumentRef(for: movie.id, from: uid))
        }
        
        try await batch.commit()
    }
    
    static func getMovie(by id: String) async throws -> Movie? {
       return nil
    }
    
    static func updateOrCreateNewMarkForMovie(movieId id: String, currentUserId uid: String, newMark mark: String) async throws
    {
        let movieRef = movieDocumentRef(for: id)
        let userRef = UserConnector.userDocumentRef(for: uid)
        let markRef = markDocumentRef(for: id, from: uid)
        let _ = try await db.runTransaction({(transaction, errorPointer) -> Any? in
            let markDocumentSnapshot: DocumentSnapshot
            do{
                try markDocumentSnapshot = transaction.getDocument(markRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            if !markDocumentSnapshot.exists {
                transaction.updateData([UserConnector.userScoreKey: FieldValue.increment(Int64(1))], forDocument: userRef)
                transaction.setData([userMarkKey: mark], forDocument: markRef)
                transaction.updateData([movieMarkComponents[0]: FieldValue.increment(Int64(mark)!), movieMarkComponents[1]: FieldValue.increment(Int64(1))], forDocument: movieRef)
                return nil
            } else {
                guard let oldMark = markDocumentSnapshot.get(userMarkKey) as? String else {
                    let error = NSError(
                        domain: "AppErrorDomain",
                        code: -1,
                        userInfo: [
                            NSLocalizedDescriptionKey: "Unable to retrieve mark from snapshot \(markDocumentSnapshot)"
                        ]
                    )
                    errorPointer?.pointee = error
                    return nil
                }
                
                
                transaction.updateData([userMarkKey: mark], forDocument: markRef)
                transaction.updateData([movieMarkComponents[0]: FieldValue.increment(Int64(mark)! - Int64(oldMark)!)], forDocument: movieRef)
                return nil
            }
        })
    }
    
    static func fetchUserMarkForMovie(movieId id: String, currentUserId uid: String) async throws -> String
    {
        let markDocument = try await markDocumentRef(for: id, from: uid).getDocument()
        if markDocument.exists {
            return (markDocument.get(userMarkKey) as? String)!
        } else {
            return ""
        }
    }
    
    static func getAllMovies() async throws -> [Movie]{
        var result : [Movie] = []
        let querySnapshot = try await db.collection(movies).order(by: "marksWholeScore").getDocuments() // TODO: get it from type
        for document in querySnapshot.documents {
            result.append(try document.data(as: Movie.self))
        }
        return result
    }
    
    // TODO: implement pagination here
    
}

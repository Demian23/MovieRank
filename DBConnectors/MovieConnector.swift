import Foundation
import SwiftUI
import Firebase
import FirebaseFirestoreSwift

let moviesCollection = "movies"
let movieMarkComponents = ["marksWholeScore", "marksAmount"]
let moviesMarksFromUserCollection = ["marks", "user"]
let userMarkKey = "userMark"

@MainActor
class MovieConnector{
    private var db = Firestore.firestore()
    
    static let shared = MovieConnector()
    
    private init(){}
    
    func addNewMovie(newMovie movie: Movie, currentUserId uid: String) async throws {
        let batch = db.batch()
        
        let encodedMovie = try Firestore.Encoder().encode(movie)
        
        let newMovieRef = db.collection(moviesCollection).document(movie.id);
        batch.setData(encodedMovie, forDocument: newMovieRef)
        
        
        if movie.marksAmount > 0{
            let newMarkRef = db.collection(moviesMarksFromUserCollection[0]).document(movie.id)
                .collection(moviesMarksFromUserCollection[1]).document(uid)
            batch.setData([userMarkKey: String(movie.marksWholeScore)], forDocument: newMarkRef)
        }
        
        try await batch.commit()
    }
    
    func updateOrCreateNewMarkForMovie(movieId id: String, currentUserId uid: String, newMark mark: String) async throws
    {
        let movieRef = db.collection(moviesCollection).document(id)
        let userRef = db.collection(usersCollection).document(uid)
        let markRef = db.collection(moviesMarksFromUserCollection[0]).document(id).collection(moviesMarksFromUserCollection[1]).document(uid)
        let _ = try await db.runTransaction({(transaction, errorPointer) -> Any? in
            let markDocumentSnapshot: DocumentSnapshot
            do{
                try markDocumentSnapshot = transaction.getDocument(markRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            if !markDocumentSnapshot.exists {
                transaction.updateData([userScoreKey: FieldValue.increment(Int64(1))], forDocument: userRef)
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
    
    func fetchUserMarkForMovie(movieId id: String, currentUserId uid: String) async throws -> String 
    {
        let markRef = db.collection(moviesMarksFromUserCollection[0]).document(id)
            .collection(moviesMarksFromUserCollection[1]).document(uid)
        let markDocument = try await markRef.getDocument()
        if markDocument.exists {
            return (markDocument.get(userMarkKey) as? String)!
        } else {
            return ""
        }
    }
    
    func getAllMovies() async throws -> [Movie]{
        var movies: [Movie] = []
        let querySnapshot = try await db.collection(moviesCollection).order(by: "marksWholeScore").getDocuments() // TODO: get it from type
        for document in querySnapshot.documents {
            movies.append(try document.data(as: Movie.self))
        }
        return movies
    }
    
    // TODO: implement pagination here
    
}

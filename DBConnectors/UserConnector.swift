import Foundation
import SwiftUI
import Firebase
import FirebaseFirestoreSwift

let usersCollection = "users"
let userScoreKey = "userScore"

@MainActor
class UserConnector {
    static let shared = UserConnector()
    private var db = Firestore.firestore()
    private init(){}

    func createNewUser(newUser user: User) async throws {
        let encodedUser = try Firestore.Encoder().encode(user)
        try await db.collection(usersCollection).document(user.id).setData(encodedUser)
    }
    
    func fetchUser(userId uid: String) async throws -> User  {
        let snapshot = try await db.collection(usersCollection).document(uid).getDocument()
        return try snapshot.data(as: User.self)
    }
    
    func deleteUserData(userId uid: String) async throws {
        try await db.collection(usersCollection).document(uid).delete()
        // Delete all marks ? or use cloud function
    }
    
    func setNewUserScore(userId uid: String, userScore score: Int) async throws {
        try await db.collection(usersCollection).document(uid).updateData([userScoreKey: score])
    }
    
    
}

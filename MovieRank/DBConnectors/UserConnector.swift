import Firebase
import Foundation

@MainActor
class UserConnector {
    static private let users = "users"
    static let userScoreKey = "userScore"
    static private var db = Firestore.firestore()
    private init() {}

    static func userDocumentRef(for uid: String) -> DocumentReference {
        return db.collection(users).document(uid)
    }

    static func createNewUser(newUser user: User) async throws {
        let encodedUser = try Firestore.Encoder().encode(user)
        try await UserConnector.userDocumentRef(for: user.id).setData(encodedUser)
    }

    static func fetchUser(userId uid: String) async throws -> User {
        return try await UserConnector.userDocumentRef(for: uid).getDocument(as: User.self)
    }

    static func deleteUserData(userId uid: String) async throws {
        let batch = db.batch()
        batch.deleteDocument(userDocumentRef(for: uid))
        batch.deleteDocument(FavouritesConnector.favouritesDocumentRef(for: uid))
        // marks? transaction?
        try await batch.commit()
    }

    static func setNewUserScore(userId uid: String, userScore score: Int) async throws {
        try await UserConnector.userDocumentRef(for: uid).updateData([
            UserConnector.userScoreKey: score
        ])
    }
    static func changeUserScore(userId uid: String, on: Int64) async throws {
        try await UserConnector.userDocumentRef(for: uid).updateData([
            UserConnector.userScoreKey: FieldValue.increment(on)
        ])
    }
}

import Firebase
import Foundation

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var currentUserSession: Firebase.User? = Auth.auth().currentUser

    init() {
        Task {
            try await fetchCurrentUser()
        }
    }

    @discardableResult
    func createUserWithEmail(withEmail email: String, password: String) async throws
        -> AuthDataResult
    {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        currentUserSession = result.user
        return result
    }

    @discardableResult
    func singInUserWithEmail(withEmail email: String, password: String) async throws
        -> AuthDataResult
    {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        currentUserSession = result.user
        return result
    }

    func sendVerificationEmailToCurrentUser() {
        if currentUserSession != nil && !currentUserSession!.isEmailVerified {
            currentUserSession!.sendEmailVerification()
        }
    }

    func singOutCurrentUserSession() throws {
        try Auth.auth().signOut()
        currentUserSession = nil
    }

    var uid: String? {
        return currentUserSession?.uid
    }

    func deleteCurrentUserAccount() async throws {
        try await currentUserSession!.delete()
        currentUserSession = nil
    }

    func sendResetPasswordEmail() async throws {
        try await Auth.auth().sendPasswordReset(withEmail: currentUser!.email)
    }

    func signIn(withEmail email: String, password: String) async throws {
        try await singInUserWithEmail(withEmail: email, password: password)
        try await fetchCurrentUser()
    }

    func createUser(
        withEmail email: String, password: String, firstName: String, lastName: String,
        country: String
    ) async throws {
        try await createUserWithEmail(withEmail: email, password: password)
        let user = User(
            id: uid!, firstName: firstName, lastName: lastName, email: email,
            role: Role.CommonUser.rawValue, country: country, userScore: 0)
        try await UserConnector.createNewUser(newUser: user)
        try await fetchCurrentUser()  // maybe throw it out
    }

    func signOut() throws {
        try singOutCurrentUserSession()
        currentUser = nil
    }

    func deleteAccount() async throws {
        guard let uid = uid else { return }
        try await deleteCurrentUserAccount()
        try await UserConnector.deleteUserData(userId: uid)
        currentUser = nil
    }

    func fetchCurrentUser() async throws {
        guard let userId = uid else { return }
        currentUser = try await UserConnector.fetchUser(userId: userId)
    }
}

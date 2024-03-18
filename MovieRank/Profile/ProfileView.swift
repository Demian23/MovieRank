import AlertToast
import Firebase
import FirebaseAuth
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authModel: AuthViewModel
    @EnvironmentObject var alert: AlertViewModel

    @State private var isReauthanticate = false
    @State private var isAlertShown = false
    @State private var messagePlacing = ""

    var body: some View {
        let user = authModel.currentUser ?? User.MOCK_USER
        let errorHandler: (Error) -> Void = { error in
            alert.alertToast = AlertToast(
                displayMode: .alert, type: .error(.red), title: "\(error.localizedDescription)")
        }

        let deleteErrorHandler: (Error) -> Void = {
            error in
            if let error = error as NSError? {
                let code = AuthErrorCode.Code(rawValue: error.code)
                if code == .requiresRecentLogin {
                    isReauthanticate = true
                } else {
                    errorHandler(error)
                }
            }
        }

        let labelProducer: (String, String) -> () -> SettingsRowView = {
            name, title in
            return { SettingsRowView(imageName: name, title: title, tintColor: .red) }
        }
        let signOutLabel = labelProducer("arrow.left.circle.fill", "Sign Out")

        let resetPassLabel = labelProducer("key.horizontal.fill", "Reset Password")

        let deleteAccLabel = labelProducer("xmark.circle.fill", "Delete Account")

        let userEmail = authModel.currentUser?.email ?? ""

        List {
            Section {
                HStack {
                    Text(user.initials).font(.title).fontWeight(.semibold).foregroundColor(.white)
                        .frame(width: 72, height: 72).background(Color(.systemGray3)).clipShape(
                            Circle())
                    VStack(alignment: .leading, spacing: 4) {
                        Text(user.firstName + " " + user.lastName).fontWeight(.semibold)
                        Text(user.email).font(.footnote).foregroundColor(Color(.systemGray))
                    }.padding(.horizontal, 15)
                }
            }

            Section("General") {
                VStack {
                    InfoLine(
                        imageName: "globe", title: "Country", valueText: user.country,
                        tintColor: Color(.systemBlue), valueColor: Color(.systemIndigo))
                    Divider()
                    InfoLine(
                        imageName: "figure.run", title: "Role", valueText: user.role,
                        tintColor: Color(.systemGreen), valueColor: Color(.systemIndigo))
                    Divider()
                    InfoLine(
                        imageName: "line.horizontal.star.fill.line.horizontal", title: "User Score",
                        valueText: String(user.userScore), tintColor: Color(.systemYellow),
                        valueColor: Color(.systemIndigo))
                }
            }

            ButtonWithResultNotificationAndErrorHandling(
                closure: { try authModel.signOut() }, errorHandler: errorHandler,
                buttonLabel: signOutLabel, newAlert: nil)
            AsyncButtonWithResultNotificationAndErrorHandling(
                closure: { try await authModel.sendResetPasswordEmail() },
                errorHandler: errorHandler, buttonLabel: resetPassLabel,
                newAlert: { AlertToast(type: .regular, title: "Check for new mail: \(userEmail)") })

            AsyncButtonWithResultNotificationAndErrorHandling(
                closure: {
                    try await authModel.deleteAccount()
                    isReauthanticate = true
                }, errorHandler: deleteErrorHandler, buttonLabel: deleteAccLabel, newAlert: nil
            )
            .confirmationDialog(
                Text("Account deleting is sensitive operation and needs re-authantication"),
                isPresented: $isReauthanticate, titleVisibility: .visible
            ) {
                Button("Ok") {
                    isReauthanticate = false
                    do {
                        try authModel.signOut()
                    } catch {
                        errorHandler(error)
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView().environmentObject(AuthViewModel())
    }
}

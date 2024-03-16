import SwiftUI
import Firebase
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var errorHandling: ErrorHandling
    @EnvironmentObject var authModel: AuthViewModel
    @State private var isReauthanticate = false
    
    var body: some View {
        
        let user = authModel.currentUser ?? User.MOCK_USER
        let errorHandler = {error in errorHandling.handle(error: error)}
        let deleteErrorHandler: (Error)->Void = {
            error in
            if let error = error as NSError?{
                let code = AuthErrorCode.Code(rawValue: error.code)
                if code == .requiresRecentLogin {
                    isReauthanticate = true
                } else {
                    errorHandling.handle(error: error)
                }
            }
        }
        
        let labelProducer: (String, String) -> () -> SettingsRowView = {
            name, title in
            return {SettingsRowView(imageName: name, title: title, tintColor: .red)}
        }
        let signOutLabel = labelProducer("arrow.left.circle.fill", "Sign Out")
        
        let resetPassLabel = labelProducer("key.horizontal.fill", "Reset Password")
        
        let deleteAccLabel = labelProducer("xmark.circle.fill", "Delete Account")
        
        let userEmail = authModel.currentUser?.email ?? ""
        
        List{
            Section{
                HStack{
                    Text(user.initials).font(.title).fontWeight(.semibold).foregroundColor(.white).frame(width: 72, height: 72).background(Color(.systemGray3)).clipShape(Circle())
                    VStack(alignment: .leading, spacing: 4){
                        Text(user.firstName + " " + user.lastName).fontWeight(.semibold)
                        Text(user.email).font(.footnote).foregroundColor(Color(.systemGray))
                    }.padding(.horizontal, 15)
                }
            }
            
            Section("General"){
                VStack{
                    InfoLine(imageName: "globe", title: "Country", valueText: user.country,tintColor: Color(.systemBlue), valueColor: Color(.systemIndigo))
                    Divider()
                    InfoLine(imageName: "figure.run", title: "Role", valueText: user.role, tintColor: Color(.systemGreen), valueColor: Color(.systemIndigo))
                    Divider()
                    InfoLine(imageName: "line.horizontal.star.fill.line.horizontal", title: "User Score", valueText: String(user.userScore), tintColor: Color(.systemYellow), valueColor: Color(.systemIndigo))
                }
            }
            
            
            ButtonWithResultNotificationAndErrorHandling(buttonLabel: signOutLabel, closure: {try authModel.signOut()}, errorHandler: errorHandler, notificationTitle:"", notificationMessage: "")
            
            AsyncButtonWithResultNotificationAndErrorHandling(closure: {try await authModel.sendResetPasswordEmail()}, errorHandler: errorHandler, buttonLabel: resetPassLabel, notificationTitle: "Info", notificationMessage: "Mail with resetting instruns is sended on \(userEmail)")
            
            AsyncButtonWithResultNotificationAndErrorHandling(closure: {try await authModel.deleteAccount(); isReauthanticate = true}, errorHandler: deleteErrorHandler, buttonLabel: deleteAccLabel, notificationTitle: "", notificationMessage: "")
                .confirmationDialog(Text("Account deleting is too sensitive operation. Reauthantication required!"), isPresented: $isReauthanticate, titleVisibility: .visible) {
                    Button("Ok"){
                        isReauthanticate = false
                        do{
                            try authModel.signOut()
                            Task{
                                try! await authModel.deleteAccount()
                            }
                        } catch {
                            errorHandling.handle(error: error)
                        }
                    }
                    Button("Cancel", role: .cancel){}
                }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView().environmentObject(AuthViewModel())
    }
}

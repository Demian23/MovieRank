import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var errorHandling: ErrorHandling
    @EnvironmentObject var authModel: AuthViewModel
    var body: some View {
        NavigationView {
            VStack {
                Image("MovieRankLogo").resizable().scaledToFit().frame(width: 600, height: 300)
                    .padding(.vertical, 30)
                VStack {
                    InputView(text: $email, title: "Email Address", placeholder: "name@gmail.com")
                        .textInputAutocapitalization(.never)
                    InputView(
                        text: $password, title: "Password", placeholder: "Enter your password",
                        isSecured: true
                    ).textInputAutocapitalization(.never)

                }.padding(.horizontal)

                Button {
                    Task {
                        do {
                            try await authModel.signIn(withEmail: email, password: password)
                        } catch {
                            self.errorHandling.handle(error: error)
                        }
                    }
                } label: {
                    HStack {
                        Text("Sign in").fontWeight(.semibold)
                        Image(systemName: "arrow.forward.to.line")
                    }.foregroundColor(.white).frame(
                        width: UIScreen.main.bounds.width - 32, height: 42)
                }
                .disabled(!isFormValid)
                .opacity((isFormValid ? 1.0 : 0.5))
                .background(Color(.systemBlue))
                .cornerRadius(10)
                .padding(.top)

                Spacer()

                NavigationLink {
                    RegistrationView().navigationBarBackButtonHidden(true)
                } label: {
                    HStack {
                        Text("Don't register yet?")
                        Text("Sign up").fontWeight(.bold)
                    }.foregroundColor(.indigo).font(.system(size: 14))
                }
            }
        }
    }
}

extension LoginView: InputFormProtocol {
    var isFormValid: Bool {
        return !email.isEmpty && email.contains("@") && !password.isEmpty && password.count > 5
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

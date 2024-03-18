import SwiftUI

struct RegistrationView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var country = ""
    @State private var confirmPassword = ""
    @Environment(\.dismiss) var dismiss

    @EnvironmentObject var errorHandling: ErrorHandling
    @EnvironmentObject var authModel: AuthViewModel
    var body: some View {
        VStack {
            Image("MovieRankLogo").resizable().scaledToFit().frame(width: 900, height: 200).padding(
                .vertical, 10)
            VStack {
                InputView(text: $email, title: "Email Address", placeholder: "name@gmail.com")
                    .textInputAutocapitalization(.never)
                InputView(
                    text: $firstName, title: "First Name", placeholder: "Enter your first name"
                ).textInputAutocapitalization(.never)
                InputView(text: $lastName, title: "Last Name", placeholder: "Enter your last name")
                    .textInputAutocapitalization(.never)
                InputView(text: $country, title: "Country", placeholder: "Enter your country")
                    .textInputAutocapitalization(.never)

                InputView(
                    text: $password, title: "Password", placeholder: "Enter your password",
                    isSecured: true
                ).textInputAutocapitalization(.never)
                ZStack(alignment: .trailing) {
                    InputView(
                        text: $confirmPassword, title: "Confirm Password",
                        placeholder: "Confirm your password", isSecured: true
                    ).textInputAutocapitalization(.never)
                    if !password.isEmpty && !confirmPassword.isEmpty {
                        if password == confirmPassword {
                            Image(systemName: "checkmark.circle.fill")
                                .imageScale(.large)
                                .fontWeight(.bold)
                                .foregroundColor(Color(.systemGray))
                        } else {
                            Image(systemName: "xmark.circle.fill")
                                .imageScale(.large)
                                .fontWeight(.bold)
                                .foregroundColor(Color(.systemRed))
                        }
                    }
                }
            }.padding(.horizontal)

            Button {
                Task {
                    do {
                        try await authModel.createUser(
                            withEmail: email, password: password, firstName: firstName,
                            lastName: lastName, country: country)
                        // send verification ?
                    } catch {
                        errorHandling.handle(error: error)
                    }
                }
            } label: {
                HStack {
                    Text("Sign up").fontWeight(.semibold)
                    Image(systemName: "arrow.forward.to.line")
                }
                .foregroundColor(.white)
                .frame(width: UIScreen.main.bounds.width - 32, height: 42)
            }
            .disabled(!isFormValid)
            .opacity((isFormValid ? 1.0 : 0.5))
            .background(Color(.systemBlue))
            .cornerRadius(10)
            .padding(.top)

            Spacer()
            Button {
                dismiss()
            } label: {
                HStack {
                    Text("Already have an account?")
                    Text("Sign in").fontWeight(.bold)
                }
            }.foregroundColor(.indigo).font(.system(size: 14))
        }
    }
}

extension RegistrationView: InputFormProtocol {
    var isFormValid: Bool {
        return !email.isEmpty && email.contains("@") && !password.isEmpty && password.count > 5
            && !firstName.isEmpty && !lastName.isEmpty && confirmPassword == password
            && !country.isEmpty
    }
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView()
    }
}

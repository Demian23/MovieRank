import SwiftUI

struct NewMovieView : View {
    @EnvironmentObject var errorHandling: ErrorHandling
    @EnvironmentObject var authModel: AuthViewModel
    @State private var name = ""
    @State private var country = ""
    @State private var genres: Set<Genres> = Set()
    @State private var director = ""
    @State private var description = ""
    @State private var mark = ""
    private var isMarkValid: Bool {
            let digitsCharacters = CharacterSet(charactersIn: "0123456789")
            return CharacterSet(charactersIn: mark).isSubset(of: digitsCharacters)
        }
    @State private var releaseDate: Date = Date()
    @State private var buttonColor = Color(.systemBlue)
    @State private var isAlertNeeded = false
    
    
    let addNewMovieLabel: () -> SettingsRowView = {
        SettingsRowView(imageName: "folder.badge.plus", title: "Add new Movie", tintColor: .white)
    }
    
    var body: some View {
        let errorHandler: (Error) -> Void = {error in errorHandling.handle(error: error)}
        
        VStack{
            NavigationView{
                Form{
                    InputView(text:$name, title: "Movie", placeholder: "Movie name").listRowSeparator(.hidden)
                    InputView(text:$country, title: "Country", placeholder: "USA, New Zeland").listRowSeparator(.hidden)
                    MultiSelector(label: Text("Genres"), options: Genres.allCases, optionToString: {$0.rawValue}, selected: $genres).foregroundColor(.black)
                    DatePicker("Select a Release Date", selection: $releaseDate, displayedComponents: .date)
                    InputView(text:$director, title: "Director", placeholder: "Joel Coen, Ethan Coen")
                    InputView(text:$description, title: "Description", placeholder: "Movie description").listRowSeparator(.hidden)
                    InputView(text:$mark, title: "Mark", placeholder: "Your mark").listRowSeparator(.hidden)
                }
            }
            
            let newMovieClosure = {
                Movie(id: NSUUID().uuidString, name: name, releaseDate: releaseDate, marksAmount: (mark.isEmpty ? 0 : 1), marksWholeScore: UInt64(mark) ?? 0, country: country.components(separatedBy: ", "), genre: genres.map{$0.rawValue}, director: director.components(separatedBy: ", "), description: description)
            }
            
            AsyncButtonWithResultNotificationAndErrorHandling(closure: {try await MovieConnector.shared.addNewMovie(newMovie: newMovieClosure(), currentUserId: authModel.uid!); try await UserConnector.shared.setNewUserScore(userId: authModel.uid!, userScore: authModel.currentUser!.userScore + 1)}, errorHandler: errorHandler, buttonLabel: addNewMovieLabel, notificationTitle: "Info", notificationMessage: "New movie \"\(name)\" successfully added")
                .frame(width: UIScreen.main.bounds.width - 32, height: 42)
                .disabled(!isFormValid)
                .opacity((isFormValid ? 1.0 : 0.5))
                .background(Color(.systemCyan))
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.top)
            
        }
    }
}

extension NewMovieView : InputFormProtocol {
    var isFormValid: Bool {
        return 
            !name.isEmpty &&
            !genres.isEmpty &&
            !description.isEmpty &&
            !description.isEmpty &&
            !director.isEmpty &&
            isMarkValid
    }
}


struct NewMovieView_Preview: PreviewProvider {
    static var previews: some View {
        NewMovieView()
    }
}

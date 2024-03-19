import AlertToast
import PhotosUI
import SwiftUI

struct NewMovie: View {
    @EnvironmentObject var alert: AlertViewModel
    @StateObject var newMovieVM: NewMovieViewModel = NewMovieViewModel()
    @StateObject var photoSelectorVM = PhotoSelectorViewModel()
    @StateObject var imagesProgress = ImagesUploadProgressObserver()
    let userId: String
    
    private let addNewMovieLabel: () -> SettingsRowView = {
        SettingsRowView(imageName: "folder.badge.plus", title: "Add new Movie", tintColor: .white)
    }

    var body: some View {
        let errorHandler: (Error) -> Void = { error in
            alert.alertToast = AlertToast(
                displayMode: .alert, type: .error(.red), title: "\(error.localizedDescription)")
        }
        VStack {
            HStack{
                Spacer()
            }
            NavigationView {
                Form {
                    InputView(text: $newMovieVM.name, title: "Movie", placeholder: "Movie name")
                        .listRowSeparator(.hidden)
                    InputView(
                        text: $newMovieVM.country, title: "Country", placeholder: "USA, New Zeland"
                    ).listRowSeparator(.hidden)
                    InputView(
                        text: $newMovieVM.duration, title: "Duration",
                        placeholder: "2:19"
                    ).listRowSeparator(.hidden)
                    MultiSelector(
                        label: Text("Genres").font(.footnote), options: Genres.allCases,
                        optionToString: { $0.rawValue }, selected: $newMovieVM.genres
                    ).foregroundColor(.black)
                    DatePicker(
                        "Release Date", selection: $newMovieVM.releaseDate,
                        displayedComponents: .date)
                    InputView(
                        text: $newMovieVM.director, title: "Director",
                        placeholder: "Joel Coen, Ethan Coen")
                    InputView(
                        text: $newMovieVM.description, title: "Description",
                        placeholder: "Movie description"
                    ).listRowSeparator(.hidden)
                    InputView(text: $newMovieVM.mark, title: "Mark", placeholder: "Your mark")
                        .listRowSeparator(.hidden)
                    PhotoSelector(size: 80).frame(
                        width: UIScreen.main.bounds.width - 32, height: 100
                    ).environmentObject(photoSelectorVM)
                    ForEach(imagesProgress.uploadProgess.indices, id: \.self) {
                        index in

                        let progress = imagesProgress.uploadProgess[index]
                        ProgressView(value: progress) { Text("\(Int(progress * 100))%") }.padding()
                            .listRowSeparator(.hidden)
                    }
                }
            }
            HStack{
                Button{
                    newMovieVM.clearAll()
                    if imagesProgress.uploadTasks.isEmpty{
                        imagesProgress.uploadProgess = []
                        photoSelectorVM.images = []
                    }
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .frame(width: 70, height: 40).foregroundColor(.black)
                }
                .background(Color(.systemCyan))
                .fontWeight(.semibold)
                .cornerRadius(10)
               Spacer()
                AsyncButtonWithResultNotificationAndErrorHandling(
                    closure: {
                        try await newMovieVM.addNewMovie(
                            by: userId, images: photoSelectorVM.images, progressObserver: imagesProgress
                        )
                        
                    }, errorHandler: errorHandler, buttonLabel: addNewMovieLabel,
                    newAlert: {
                        AlertToast(
                            type: .regular, title: "New movie \"\(newMovieVM.name)\" successfully added"
                        )
                    }
                )
                .frame(width: UIScreen.main.bounds.width - 120, height: 42)
                .disabled(!isFormValid)
                .opacity((isFormValid ? 1.0 : 0.5))
                .background(Color(.systemCyan))
                .fontWeight(.semibold)
                .cornerRadius(10)
            }.padding(.horizontal)
            .padding(.top)
            .foregroundColor(.white)
        }
    }
}

extension NewMovie: InputFormProtocol {
    var isFormValid: Bool {
        return newMovieVM.isInputValid()
    }
}

struct NewMovieView_Preview: PreviewProvider {
    static var previews: some View {
        NewMovie(userId: "").environmentObject(AlertViewModel())
    }
}

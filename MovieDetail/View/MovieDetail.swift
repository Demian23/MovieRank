import SwiftUI

struct MovieDetail: View {
    let movie: Movie
    @State var mark: String = ""
    @EnvironmentObject var authModel: AuthViewModel
    @EnvironmentObject var errorHandling: ErrorHandling
    @State var initFinished = false
    
    var body: some View {
        let errorHandler = {error in errorHandling.handle(error: error)}
        
        ScrollView{
            VStack{
                Image(systemName: "photo.circle").resizable().aspectRatio(contentMode: .fit).padding(.top, 30.0).frame(width: 300, height: 400)
                HStack{
                    Text(movie.name)
                    Spacer()
                    Text(movie.marksWholeScore / movie.marksAmount, format: .number).fontDesign(.serif)
                }.padding(.horizontal,  70.0).padding(.bottom, 5.0).font(.largeTitle).bold()
                Divider()
                HStack{
                    Text(movie.genre.joined(separator: ", ")).font(.subheadline).foregroundColor(Color(.systemGray)).padding(.leading)
                    Spacer()
                    Text(movie.country.joined(separator: ", ")).font(.subheadline).foregroundColor(Color(.systemGray)).padding(.trailing)
                }
                
                                                              
                HStack{
                    InputView(text: $mark, title: "Your mark", placeholder: mark)
                    Spacer()
                    AsyncButtonWithResultNotificationAndErrorHandling(closure: {try await MovieConnector.shared.updateOrCreateNewMarkForMovie(movieId: movie.id, currentUserId: authModel.uid!, newMark: mark)}, errorHandler: errorHandler, buttonLabel: {Text("Rank")},notificationTitle: "Info", notificationMessage: "Mark changed to \(mark).")
                        .background(Color(.systemBlue))
                        .cornerRadius(10)
                        .padding(.top)
                }
                .padding(.top)
                .padding(.horizontal)
                .onAppear{
                    if !initFinished {
                        Task{
                            mark = try await MovieConnector.shared.fetchUserMarkForMovie(movieId: movie.id, currentUserId: authModel.uid!)
                            initFinished = true
                        }
                    }
                }
                
                Text("Director(s): \( movie.director.joined(separator: ", "))").padding(.top).padding(.horizontal).font(.callout)
                Divider()
                Text(movie.description).multilineTextAlignment(.leading).font(.title3)
            }
        }
        .navigationTitle(movie.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MovieDetail_Previews: PreviewProvider {
    static var previews: some View {
        MovieDetail(movie: Movie(id: NSUUID().uuidString, name: "Matrix", releaseDate: Date(), marksAmount: 1, marksWholeScore: 90, country: ["USA", "New Zeland"], genre: [Genres.Action.rawValue, Genres.Science.rawValue], director: ["Lilly Wachovsky", "Lola Wachovsky"], description: "Bad future"), mark: "90")
    }
}

import SwiftUI

struct MovieDetail: View {
    @EnvironmentObject var errorHandling: ErrorHandling
    let movie = Movie(id: "", name: "", releaseDate: Date(), marksAmount: 0, marksWholeScore: 0, country: [], genre: [], director: [], description: "")
    let isFavourite = false
    let userId = ""
    @State var mark = ""
    
    init(){
        Task{
            
        }
    }
    
    var body: some View {
        let errorHandler = {error in errorHandling.handle(error: error)}
        
        ScrollView{
            HStack {
                /*
                AsyncButtonWithResultNotificationAndErrorHandling(closure: {if !isFavourite {try await UserConnector.addFavouritesForUser(movieId: movie.id, userId: userId)} else {
                    try await UserConnector.deleteFavouritesForUser(movieId: movie.id, userId: userId)
                }}, errorHandler: {error in errorHandling.handle(error: error)}, buttonLabel: {Image(systemName: isFavourite ? "star.fill" : "star")}, notificationTitle: "", notificationMessage: "")
                 */
            }
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
                    AsyncButtonWithResultNotificationAndErrorHandling(closure: {try await MovieConnector.updateOrCreateNewMarkForMovie(movieId: movie.id, currentUserId: userId, newMark: mark)}, errorHandler: errorHandler, buttonLabel: {
                        Text("Rank")
                        .foregroundColor(.white)
                        .frame(width: 100, height: 40)
                        
                        },notificationTitle: "Info", notificationMessage: "Mark changed to \(mark).")
                        .background(Color(.systemBlue))
                        .cornerRadius(10)
                        .padding(.top)
                }
                .padding(.top)
                .padding(.horizontal)
                
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
        MovieDetail()//movie: Movie(id: NSUUID().uuidString, name: "Matrix", releaseDate: Date(), marksAmount: 1, marksWholeScore: 90, country: ["USA", "New Zeland"], genre: [Genres.Action.rawValue, Genres.Science.rawValue], director: ["Lilly Wachovsky", "Lola Wachovsky"], description: "Bad future"), mark: "90", userId:"uid").environmentObject(ErrorHandling())
    }
}

import SwiftUI

struct MovieDetail: View {
    @EnvironmentObject var errorHandling: ErrorHandling
    
    private let movie: Movie
    private var onMarkUpdate: (String) async throws -> Void
    private var onFavouritesStateChanging: (Bool) async throws -> Void
    private var fetchAllDetailData: FetchAllDetailDataType
    @State public var editedMark: String = ""
    @State public var isFavourite: Bool = false
    typealias FetchAllDetailDataType = (@escaping (String, Bool) -> Void) -> Void
    
    init(movie: Movie, onMarkUpdate: @escaping (String) async throws -> Void,
         onFavouritesStateChanging: @escaping (Bool) async throws -> Void,
         fetchAllDetailData: @escaping FetchAllDetailDataType)
    {
        self.movie = movie
        self.onMarkUpdate = onMarkUpdate
        self.onFavouritesStateChanging = onFavouritesStateChanging
        self.fetchAllDetailData = fetchAllDetailData
    }
    
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
                    AsyncButtonWithResultNotificationAndErrorHandling(closure: {isFavourite = !isFavourite; try await onFavouritesStateChanging(isFavourite)}, errorHandler: errorHandler, buttonLabel: {Image(systemName: isFavourite ? "star.fill" : "star")}, notificationTitle: "", notificationMessage: "")
                    InputView(text: $editedMark, title: "Your mark", placeholder: editedMark).padding(.horizontal)
                    Spacer()
                    AsyncButtonWithResultNotificationAndErrorHandling(closure: {try await onMarkUpdate(editedMark)}, errorHandler: errorHandler, buttonLabel: {Text("Rank").foregroundColor(.white).frame(width: 70, height: 40)}, notificationTitle: "", notificationMessage: "")
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
        .onAppear{
            fetchAllDetailData {mark, favourite in
                DispatchQueue.main.async {
                    self.editedMark = mark
                    self.isFavourite = favourite
                }
            }
        }
    }
}

struct MovieDetail_Previews: PreviewProvider {
    static var previews: some View {
        let closure: MovieDetail.FetchAllDetailDataType = {completion in completion("90", true)}
        MovieDetail(movie: Movie(id: NSUUID().uuidString, name: "Matrix", releaseDate: Date(), marksAmount: 1, marksWholeScore: 90, country: ["USA", "New Zeland"], genre: [Genres.Action.rawValue, Genres.Science.rawValue], director: ["Lilly Wachovsky", "Lola Wachovsky"], description: "Bad future"), onMarkUpdate: {mark in }, onFavouritesStateChanging: {val in }, fetchAllDetailData: closure).environmentObject(ErrorHandling())
    }
}

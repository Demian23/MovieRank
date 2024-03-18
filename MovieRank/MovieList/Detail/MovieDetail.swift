import SwiftUI
import AlertToast

struct MovieDetail: View {
    @EnvironmentObject var alert: AlertViewModel
    private let movie: Movie
    private var onMarkUpdate: (String) async throws -> Void
    private var onFavouritesStateChanging: (Bool) async throws -> Bool
    private var fetchAllDetailData: FetchAllDetailDataType
    
    @State private var images: [UIImage] = []
    @State private var editedMark: String = ""
    @State private var isFavourite: Bool = false
    
    typealias FetchAllDetailDataType = (@escaping (String, Bool) -> Void, @escaping (UIImage)->Void) -> Void
    
    init(movie: Movie, onMarkUpdate: @escaping (String) async throws -> Void,
         onFavouritesStateChanging: @escaping (Bool) async throws -> Bool,
         fetchAllDetailData: @escaping FetchAllDetailDataType)
    {
        self.movie = movie
        self.onMarkUpdate = onMarkUpdate
        self.onFavouritesStateChanging = onFavouritesStateChanging
        self.fetchAllDetailData = fetchAllDetailData
    }
    
    var body: some View {
        let errorHandler : (Error)->Void = {error in
            alert.alertToast = AlertToast(displayMode: .alert, type: .error(.red), title: "\(error.localizedDescription)")}
        ScrollView{
            VStack{
                HStack{
                    if images.count > 0 {
                        UIImageScroller(images: $images)
                    } else {
                        Image(systemName: "photo.circle").resizable().aspectRatio(contentMode: .fit).padding(.top, 30.0).frame(width: 300, height: 400)
                    }
                }
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
                    AsyncButtonWithResultNotificationAndErrorHandling(closure: {isFavourite = try await onFavouritesStateChanging(isFavourite)}, errorHandler: errorHandler, buttonLabel: {Image(systemName: isFavourite ? "star.fill" : "star")}, newAlert: {AlertToast(type: .complete(Color(.systemYellow)))})
                    InputView(text: $editedMark, title: "Your mark", placeholder: editedMark).padding(.horizontal)
                    Spacer()
                    AsyncButtonWithResultNotificationAndErrorHandling(closure: {try await onMarkUpdate(editedMark)}, errorHandler: errorHandler, buttonLabel: {Text("Rank").foregroundColor(.white).frame(width: 70, height: 40)}, newAlert: {AlertToast(type: .complete(Color(.systemGreen)), title: "Mark changed to \(editedMark)")})
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
            fetchAllDetailData({mark, favourite in
                DispatchQueue.main.async {
                    self.editedMark = mark
                    self.isFavourite = favourite
                }
            }, {images in
                    DispatchQueue.main.async {
                        self.images.append(images)
                    }
                })
        }
    }
}

struct MovieDetail_Previews: PreviewProvider {
    static var previews: some View {
        let closure: MovieDetail.FetchAllDetailDataType = {completion, photo in completion("90", true); photo(UIImage())}
        MovieDetail(movie: Movie(id: NSUUID().uuidString, name: "Matrix", releaseDate: Date(), marksAmount: 1, marksWholeScore: 90, country: ["USA", "New Zeland"], genre: [Genres.Action.rawValue, Genres.Science.rawValue], director: ["Lilly Wachovsky", "Lola Wachovsky"], description: "Bad future"), onMarkUpdate: {mark in }, onFavouritesStateChanging: {val in !val}, fetchAllDetailData: closure).environmentObject(ErrorHandling())
    }
}

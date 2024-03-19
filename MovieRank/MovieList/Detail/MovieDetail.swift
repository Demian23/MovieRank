import AlertToast
import SwiftUI

struct MovieDetail: View {
    @EnvironmentObject var alert: AlertViewModel
    private let movie: Movie
    private var onMarkUpdate: (String) async throws -> Void
    private var onFavouritesStateChanging: (FavouritesPurpose, FavouritesProperties) async throws -> FavouritesPurpose
    private var fetchAllDetailData: FetchAllDetailDataType

    @State private var images: [UIImage] = []
    @State private var editedMark: String = ""
    @State private var favouriteState: FavouritesPurpose = FavouritesPurpose.none

    typealias FetchAllDetailDataType = (
        @escaping (String, FavouritesProperties?) -> Void, @escaping (UIImage) -> Void
    ) -> Void

    static func formatDate(date: Date) -> String {
        let format = DateFormatter()
        format.dateStyle = .medium
        format.timeStyle = .none
        return format.string(from: date)
    }

    init(
        movie: Movie, onMarkUpdate: @escaping (String) async throws -> Void,
        onFavouritesStateChanging: @escaping (FavouritesPurpose,  FavouritesProperties) async throws -> FavouritesPurpose,
        fetchAllDetailData: @escaping FetchAllDetailDataType
    ) {
        self.movie = movie
        self.onMarkUpdate = onMarkUpdate
        self.onFavouritesStateChanging = onFavouritesStateChanging
        self.fetchAllDetailData = fetchAllDetailData
    }

    var body: some View {
        let errorHandler: (Error) -> Void = { error in
            alert.alertToast = AlertToast(
                displayMode: .alert, type: .error(.red), title: "\(error.localizedDescription)")
        }
        ScrollView {
            VStack {
                HStack {
                    if images.count > 0 {
                        UIImageScroller(images: $images)
                    } else {
                        Image(systemName: "photo.circle").resizable().aspectRatio(contentMode: .fit)
                            .padding(.top, 30.0).frame(width: 300, height: 400)
                    }
                }

                HStack {
                    Text(movie.name)
                    Spacer()
                    Text(
                        String(
                            MovieRow.formatAverageMark(
                                whole: movie.marksWholeScore, amount: movie.marksAmount)))
                }.padding(.horizontal, 70.0).padding(.bottom, 5.0).font(.largeTitle).bold()
                Divider()
                HStack {
                    Text(movie.genre.joined(separator: ", ")).font(.headline).foregroundColor(
                        Color(.systemGray)
                    )
                }

                HStack {
                    VStack {
                        AsyncButtonWithResultNotificationAndErrorHandling(
                            closure: {
                                favouriteState = try await onFavouritesStateChanging(
                                    favouriteState, FavouritesProperties(purpose: .Favourite))
                            },
                            errorHandler: errorHandler,
                            buttonLabel: { Image(systemName: favouriteState == FavouritesPurpose.Favourite ? "star.fill" : "star") },
                            newAlert: { AlertToast(type: .complete(Color(.systemYellow))) })
                        Spacer()
                        AsyncButtonWithResultNotificationAndErrorHandling(
                            closure: {
                                favouriteState = try await onFavouritesStateChanging(
                                    favouriteState, FavouritesProperties(purpose: .WatchLater))
                            },
                            errorHandler: errorHandler,
                            buttonLabel: { Image(systemName: favouriteState == FavouritesPurpose.WatchLater ? "film.fill" : "film") },
                            newAlert: { AlertToast(type: .complete(Color(.systemYellow))) })
                    }.frame(width: 50, height: 60)
                    InputView(text: $editedMark, title: "Your mark", placeholder: editedMark)
                        .padding(.horizontal)
                    Spacer()
                    AsyncButtonWithResultNotificationAndErrorHandling(
                        closure: { try await onMarkUpdate(editedMark) }, errorHandler: errorHandler,
                        buttonLabel: {
                            Image(systemName: "seal").foregroundColor(.white).frame(
                                width: 70, height: 40)
                        },
                        newAlert: {
                            AlertToast(
                                type: .complete(Color(.systemGreen)),
                                title: "Mark changed to \(editedMark)")
                        }
                    )
                    .background(Color(.systemBlue))
                    .cornerRadius(10)
                }
                .padding(.top)
                .padding(.horizontal)
                Divider()
                VStack {
                    HStack {
                        Text("Director" + (movie.director.count > 1 ? "s:" : ":"))
                        Spacer()
                        Text(movie.director.joined(separator: ", "))
                    }
                    HStack {
                        Text("Countr" + (movie.country.count > 1 ? "ies:" : "y:"))
                        Spacer()
                        Text(movie.country.joined(separator: ", "))
                    }
                    HStack {
                        Text("Duration:")
                        Spacer()
                        Text(movie.duration.stringFromTimeInterval())
                    }
                    HStack {
                        Text("Release Date:")
                        Spacer()
                        Text(MovieDetail.formatDate(date: movie.releaseDate))
                    }
                }.padding()
                Divider()
                Text(movie.description).multilineTextAlignment(.leading).font(.title3).padding(.horizontal)
            }
        }
        .navigationTitle(movie.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fetchAllDetailData(
                { mark, propOptional in
                    DispatchQueue.main.async {
                        self.editedMark = mark
                        self.favouriteState = propOptional?.purpose ?? .none
                        
                    }
                },
                { images in
                    DispatchQueue.main.async {
                        self.images.append(images)
                    }
                })
        }.fontDesign(.serif)
    }
}

struct MovieDetail_Previews: PreviewProvider {
    static var previews: some View {
        let closure: MovieDetail.FetchAllDetailDataType = { completion, photo in
            completion("90", FavouritesProperties(purpose: .WatchLater))
            photo(UIImage())
        }
        MovieDetail(
            movie: Movie(
                id: NSUUID().uuidString, name: "Matrix", releaseDate: Date.now, marksAmount: 12,
                marksWholeScore: 1005, country: ["USA", "New Zeland"],
                genre: [Genres.Action.rawValue, Genres.SciFi.rawValue],
                director: ["Lilly Wachovsky", "Lola Wachovsky"], description: "Bad future",
                duration: 3610),
            onMarkUpdate: { mark in }, onFavouritesStateChanging: { val, prop in val},
            fetchAllDetailData: closure
        ).environmentObject(ErrorHandling())
    }
}

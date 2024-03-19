import SwiftUI

struct Favourites: View {
    @EnvironmentObject var moviesModel: MovieListViewModel
    @EnvironmentObject var errorHandling: ErrorHandling
    @StateObject var favouritesModel = FavouritesViewModel()

    let userId: String

    var body: some View {
        NavigationStack {
            List {
                ForEach(favouritesModel.filteredMovies) {
                    movie in
                    NavigationLink {
                        MovieDetail(
                            movie: movie,
                            onMarkUpdate: { mark in
                                try await moviesModel.onMarkUpdate(
                                    for: movie.id,
                                    from: userId,
                                    mark: mark,
                                    completion: { newMovie in
                                        moviesModel.localUpdate(newMovie: newMovie)
                                        favouritesModel.localUpdate(newMovie: newMovie)
                                    })
                            },
                            onFavouritesStateChanging: { favourite, prop in
                                try await moviesModel.onFavouritesChange(
                                    for: movie.id,
                                    from: userId,
                                    isFavourite: favourite, properties: prop)
                            },
                            fetchAllDetailData: { completion, image in
                                moviesModel.fetchDetailData(
                                    for: movie.id,
                                    from: userId,
                                    completion: completion, imagesCallback: image)
                            }
                        )
                    } label: {
                        FavouritesRow(movie: movie)
                    }
                }
            }
            .navigationTitle("Movies")
            .searchable(text: $favouritesModel.searchText)
            .onAppear {
                if !favouritesModel.isFetched {
                    favouritesModel.fetchFavouritesWithLookUp(userId: userId, with: moviesModel)
                    favouritesModel.isFetched = true
                }
            }
        }
    }
}

import SwiftUI

struct MovieList: View {
    @EnvironmentObject var moviesModel: MovieListViewModel
    let userId: String
    
    var body: some View {
        NavigationStack{
            List{
                ForEach(moviesModel.filteredMovies){
                    movie in NavigationLink{
                        MovieDetail(movie: movie,
                            onMarkUpdate: {mark in 
                            try await moviesModel.onMarkUpdate(
                                for: movie.id, 
                                from: userId, 
                                mark: mark, completion: moviesModel.localUpdate)
                            },
                            onFavouritesStateChanging: {isFavourite in 
                                try await moviesModel.onFavouritesChange(
                                    for: movie.id, 
                                    from: userId, 
                                    isFavourite: isFavourite)
                            }, 
                                fetchAllDetailData: {completion in
                                    moviesModel.fetchDetailData(
                                    for: movie.id, 
                                    from: userId, 
                                    completion: completion)
                            } 
                        )
                    } label: {
                        MovieRow(movie: movie)
                    }
                }
            }
            .navigationTitle("Movies")
            .searchable(text: $moviesModel.searchText)
        }
    }
}

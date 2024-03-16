import SwiftUI
/*

struct Favourites: View {
    @EnvironmentObject var fav: FavouritesViewModel
    let userId: String
    
    var body: some View {
        NavigationStack{
            List{
                ForEach(fav.filteredMovies){
                    favouriteMovie in NavigationLink {
                        MovieDetail(movie: favouriteMovie.movie, userId: userId)
                    } label: {
                        Image(systemName: favouriteMovie.purpose == FavouritesPurpose.WatchLater.rawValue ? "tv" : "star.fill")
                        MovieRow(movie: favouriteMovie.movie)
                    }
                }
            }
            .navigationTitle("Favourites")
            .searchable(text: $fav.searchText)
        }
    }
}
*/

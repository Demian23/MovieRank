import SwiftUI

struct MovieList: View {
    @EnvironmentObject var moviesModel : MovieListViewModel
    
    var body: some View {
        NavigationStack{
            List{
                ForEach(moviesModel.filteredMovies){
                    movie in NavigationLink{
                        MovieDetail(movie: movie)
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

struct MovieList_Previews: PreviewProvider {
    static var previews: some View {
        MovieList()
    }
}

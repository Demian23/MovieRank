import SwiftUI

struct MovieList: View {
    @EnvironmentObject var moviesModel: MovieListViewModel
    let userId: String
    
    var body: some View {
        NavigationStack{
            List{
                ForEach(moviesModel.filteredMovies){
                    movie in NavigationLink{
                        //MovieDetail(movie: movie, userId: userId)
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
        MovieList(userId: "") //.environmentObject(MovieListViewModel())
    }
}

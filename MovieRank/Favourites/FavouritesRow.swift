import SwiftUI

struct FavouritesRow: View {
    var movie: Movie
    var body: some View {
        HStack {
            if movie.favouritesProperties != nil {
                Image(systemName: movie.favouritesProperties!.purpose.toImageName())
            }
            Image(systemName: MovieRow.genreToImageName(movie.genre.first!)).imageScale(.large)
                .padding(.horizontal)
            Text(movie.name).font(.title2).fontWeight(.medium).padding(.horizontal)
            Spacer()
            Text(movie.marksWholeScore / movie.marksAmount, format: .number).fontDesign(.rounded)
                .padding(.horizontal)
        }
    }
}

struct FavouritesRow_Previews: PreviewProvider {
    static var previews: some View {
        FavouritesRow(
            movie: Movie(
                id: NSUUID().uuidString, name: "Matrix", releaseDate: Date(), marksAmount: 1,
                marksWholeScore: 90, country: ["USA", "New Zeland"],
                genre: [Genres.Action.rawValue, Genres.Science.rawValue],
                director: ["Lilly Wachovsky", "Lola Wachovsky"], description: "Bad future",
                favouritesProperties: FavouritesProperties(purpose: FavouritesPurpose.WatchLater)))
    }
}

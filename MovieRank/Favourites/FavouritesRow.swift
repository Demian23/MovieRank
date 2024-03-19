import SwiftUI

struct FavouritesRow: View {
    var movie: Movie
    var body: some View {
        HStack {
            if movie.favouritesProperties != nil {
                Image(systemName: movie.favouritesProperties!.purpose.toImageName())
            }
            MovieRow(movie: movie)
        }
    }
}

struct FavouritesRow_Previews: PreviewProvider {
    static var previews: some View {
        FavouritesRow(
            movie: Movie(
                id: NSUUID().uuidString, name: "Matrix", releaseDate: Date(), marksAmount: 1,
                marksWholeScore: 90, country: ["USA", "New Zeland"],
                genre: [Genres.Action.rawValue, Genres.SciFi.rawValue],
                director: ["Lilly Wachovsky", "Lola Wachovsky"], description: "Bad future",
                duration: 3600,
                favouritesProperties: FavouritesProperties(purpose: FavouritesPurpose.WatchLater)))
    }
}

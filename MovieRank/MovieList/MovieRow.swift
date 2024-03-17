import SwiftUI

struct MovieRow: View {
    var movie: Movie
    static var formatter: DateFormatter{
        let format = DateFormatter()
        format.dateStyle = .medium
        format.timeStyle = .none
        return format
    }
    
    var body: some View {
        HStack {
            Image(systemName: MovieRow.genreToImageName(movie.genre.first!)).imageScale(.large).padding(.trailing, 5)
            Text(movie.name).font(.title2).fontWeight(.medium)
            Spacer()
            Text(MovieRow.formatter.string(from: movie.releaseDate))
            Text(movie.marksWholeScore / movie.marksAmount, format: .number).fontDesign(.rounded)
        }
    }
    
    public static func genreToImageName(_ genre: String) -> String{
        switch(genre){
        case Genres.Action.rawValue:
            return "figure.walk"
        case Genres.Comedy.rawValue:
            return "gobackward"
        case Genres.Detective.rawValue:
            return "magnify1ngglass"
        case Genres.Western.rawValue:
            return "photo.artframe"
        default:
            return "questionmark"
        }
    }
}

struct MyPreviewProvider_Previews: PreviewProvider {
    static var previews: some View {
        MovieRow(movie: Movie(id: NSUUID().uuidString, name: "Matrix", releaseDate: Date(), marksAmount: 1, marksWholeScore: 90, country: ["USA", "New Zeland"], genre: [Genres.Action.rawValue, Genres.Science.rawValue], director: ["Lilly Wachovsky", "Lola Wachovsky"], description: "Bad future"))
    }
}

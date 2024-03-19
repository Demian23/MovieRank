import SwiftUI

struct MovieRow: View {
    var movie: Movie
    static func formatDate(date: Date) -> String {
        let format = DateFormatter()
        format.dateFormat = "yyyy"
        return format.string(from: date)
    }

    static func formatAverageMark(whole: UInt64, amount: UInt64) -> Double {
        return round((Double(whole) / Double(amount)) * 100) / 100
    }

    static func markToColor(mark: Double) -> Color {
        switch mark {
        case 0...30:
            return Color(.systemGray)
        case 31...69:
            return Color(.systemRed)
        case 70...89:
            return Color(.magenta)
        case 90...100:
            return Color(.systemIndigo)
        default:
            return Color.black
        }
    }

    var body: some View {
        HStack {
            let avgMark = MovieRow.formatAverageMark(
                whole: movie.marksWholeScore, amount: movie.marksAmount)
            let color = MovieRow.markToColor(mark: avgMark)
            Text(MovieRow.genreToShort(movie.genre.first!)).fontDesign(.rounded).font(.headline)
                .fontWeight(.thin).padding(.trailing)
            Text(movie.name).font(.title2).fontWeight(.medium).fontDesign(.monospaced)
            Text(MovieRow.formatDate(date: movie.releaseDate)).fontDesign(.monospaced).padding(
                .horizontal)
            Spacer()
            Text(String(avgMark))
                .fontDesign(.rounded)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(color)
                .padding(.horizontal)
        }
    }

    public static func genreToShort(_ genre: String) -> String {
        switch genre {
        case Genres.Action.rawValue:
            return "Act"
        case Genres.Adventure.rawValue:
            return "Adv"
        case Genres.Biography.rawValue:
            return "Bio"
        case Genres.Comedy.rawValue:
            return "Com"
        case Genres.Crime.rawValue:
            return "Cr"
        case Genres.Drama.rawValue:
            return "Dr"
        case Genres.Documentary.rawValue:
            return "Doc"
        case Genres.Detective.rawValue:
            return "Det"
        case Genres.Fantasy.rawValue:
            return "F"
        case Genres.History.rawValue:
            return "H"
        case Genres.Horror.rawValue:
            return "Hor"
        case Genres.Musical.rawValue:
            return "Mus"
        case Genres.Noir.rawValue:
            return "N"
        case Genres.Romance.rawValue:
            return "R"
        case Genres.SciFi.rawValue:
            return "SF"
        case Genres.Sport.rawValue:
            return "S"
        case Genres.Thriller.rawValue:
            return "Th"
        case Genres.War.rawValue:
            return "War"
        case Genres.Western.rawValue:
            return "Wes"
        case Genres.Other.rawValue:
            return "Oth"
        default:
            return ""
        }
    }
}

struct MyPreviewProvider_Previews: PreviewProvider {
    static var previews: some View {
        MovieRow(
            movie: Movie(
                id: NSUUID().uuidString, name: "Matrix", releaseDate: Date(), marksAmount: 1,
                marksWholeScore: 81, country: ["USA", "New Zeland"],
                genre: [Genres.Action.rawValue, Genres.SciFi.rawValue],
                director: ["Lilly Wachovsky", "Lola Wachovsky"], description: "Bad future",
                duration: 3600))
    }
}

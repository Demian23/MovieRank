import Foundation

enum Genres: String, CaseIterable, Identifiable, Hashable {
    var id: Self {
        return self
    }
    case Action
    case Adventure
    case Biography
    case Comedy
    case Crime
    case Drama
    case Documentary
    case Detective
    case Fantasy
    case History
    case Horror
    case Musical
    case Noir
    case Romance
    case SciFi
    case Sport
    case Thriller
    case War
    case Western
    case Other

}

public struct Movie: Identifiable, Codable {
    public let id: String
    let name: String
    let releaseDate: Date
    let marksAmount: UInt64
    let marksWholeScore: UInt64
    let country: [String]
    let genre: [String]
    let director: [String]
    let description: String
    let duration: TimeInterval
    var favouritesProperties: FavouritesProperties? = nil
}

extension TimeInterval {
    func stringFromTimeInterval() -> String {
        let time = NSInteger(self)
        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)
        return String(format: "%0.2d:%0.2d:%0.2d", hours, minutes, seconds)
    }

}

extension String {
    func toTimeInterval() -> TimeInterval {
        guard self != "" else { return 0 }
        var interval: TimeInterval = 0
        let parts = self.components(separatedBy: ":")
        for (index, part) in parts.reversed().enumerated() {
            interval += (Double(part) ?? 0) * pow(Double(60), Double(index))
        }
        return interval
    }
}

struct FavouritesProperties: Codable {
    let purpose: FavouritesPurpose
}

enum FavouritesPurpose: String, Codable {
    case WatchLater
    case Favourite

    func toImageName() -> String {
        switch self {
        case .WatchLater:
            return "film"
        case .Favourite:
            return "star.square"
        }
    }
}

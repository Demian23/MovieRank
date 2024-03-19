import Foundation
import SwiftUI

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
    case Mistery
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
        let minutes = (time / 60) % 60
        let hours = (time / 3600)
        return String(format: "%0.2dh%0.2dm", hours, minutes)
    }

}

extension String {
    func toTimeInterval() -> TimeInterval {
        guard self != "" else { return 0 }
        var interval: TimeInterval = 0
        let parts = self.components(separatedBy: ":")
        for (index, part) in parts.reversed().enumerated() {
            interval += (Double(part) ?? 0) * pow(Double(60), Double(index+1))
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
    case none

    func toColor() -> Color{
        switch self {
        case .WatchLater:
            return Color(.systemMint)
        case .Favourite:
            return Color(.systemIndigo)
        case .none:
            return Color(.black)
        }
    }
}

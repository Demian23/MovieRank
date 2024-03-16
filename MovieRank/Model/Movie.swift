import Foundation

enum Genres : String, CaseIterable, Identifiable, Hashable{
    var id: Self{
        return self
    }
    case Action
    case Comedy
    case Crime
    case Drama
    case Fantasy
    case Historical
    case Horror
    case Romance
    case Science
    case Detective
    case Thriller
    case Western
    case Other
}

// by default nil values don't encoded
// TODO: check this
struct Movie : Identifiable, Codable{
    let id: String
    let name: String
    let releaseDate: Date
    let marksAmount: UInt64
    let marksWholeScore: UInt64
    let country: [String]
    let genre: [String]
    let director: [String]
    let description: String
    var favouritesProperties: FavouritesProperties? = nil
}

struct FavouritesProperties: Codable{
    let purpose: FavouritesPurpose
}

enum FavouritesPurpose: String, Codable {
    case WatchLater
    case Favourite
}

//
//  Movie.swift
//  MovieRank
//
//  Created by Egor on 1.03.24.
//

import Foundation
import SwiftUI


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

// TODO: Add release date and country
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
}


//
//  User.swift
//  MovieRank
//
//  Created by Egor on 3.03.24.
//

import Foundation

enum Role: String {
    case CommonUser
    case Admin
}

struct User: Identifiable, Codable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    let role: String
    let country: String
    let userScore: Int

    var initials: String {
        var temp = String(firstName.first!)
        temp.append(lastName.first!)
        return temp
    }
}

extension User {
    static var MOCK_USER = User(
        id: NSUUID().uuidString, firstName: "Michel", lastName: "Jordan", email: "mg@gmail.com",
        role: Role.CommonUser.rawValue, country: "United States", userScore: 0)
}

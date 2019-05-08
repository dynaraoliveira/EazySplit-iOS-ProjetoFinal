//
//  User.swift
//  EazySplit
//
//  Created by Dynara Rico Oliveira on 25/04/19.
//  Copyright © 2019 Dynara Rico Oliveira. All rights reserved.
//

import Foundation

struct User: Codable {
    var name: String
    var email: String
    var phoneNumber: String
    var birthDate: Date
    var password: String
    var photoURL: String
    var cards: [Card]?
}

struct Card: Codable {
    var id: String
    var number: String
    var name: String
    var flag: String
    var codeValidate: Int
    var monthValidate: Int
    var yearValidate: Int
    var document: String
}

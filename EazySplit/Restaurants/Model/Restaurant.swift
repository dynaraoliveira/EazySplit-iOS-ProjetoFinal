//
//  Restaurant.swift
//  EazySplit
//
//  Created by Dynara Rico Oliveira on 21/04/19.
//  Copyright © 2019 Dynara Rico Oliveira. All rights reserved.
//

import Foundation

struct Restaurant: Codable {
    let id: String
    let name: String
    let urlImage: String
    let type: String
    let description: String
    let rating: Int
    let address: String
    let latitude: Double
    let longitude: Double
}

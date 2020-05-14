//
//  HeroesCollectionViewCellModel.swift
//  DotaHeroes
//
//  Created by Ernest Sheridan on 13/05/20.
//  Copyright © 2020 Ernest Sheridan. All rights reserved.
//

import Foundation

class HeroesCollectionViewCellModel {
    var id: Int
    var name: String
    var subtitle: String
    var description: String
    var imageUrl: URL?
    
    init(id: Int, name: String, attackType: String, roles: [String], imageUrl: String) {
        self.id = id
        self.name = name
        self.subtitle = attackType
        self.description = roles.joined(separator: ", ")
        self.imageUrl = URL(string: imageUrl)
    }
}

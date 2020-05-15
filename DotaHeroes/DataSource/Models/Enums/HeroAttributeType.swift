//
//  HeroAttributeType.swift
//  DotaHeroes
//
//  Created by Ernest Sheridan on 15/05/20.
//  Copyright © 2020 Ernest Sheridan. All rights reserved.
//

import Foundation

enum HeroAttributeType: String {
    case strength = "str"
    case agility = "agi"
    case intelligence = "int"
    case unknown = "UNKNOWN"
    
    static func get(identifier: String) -> HeroAttributeType {
        return HeroAttributeType(rawValue: identifier) ?? .unknown
    }
}

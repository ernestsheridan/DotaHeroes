//
//  Hero.swift
//  DotaHeroes
//
//  Created by Ernest Sheridan on 13/05/20.
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

protocol HeroProtocol {
    var id: Int { get }
    var name: String { get }
    var localizedName: String { get }
    var primaryAttr: String { get }
    var attackType: String { get }
    var roles: [String] { get }
    var img: String { get }
    var icon: String { get }
    var baseHealth: Int { get }
    var baseMana: Int { get }
    var baseAttackMax: Int { get }
    var baseStr: Int { get }
    var baseAgi: Int { get }
    var baseInt: Int { get }
    var strGain: Double { get }
    var agiGain: Double { get }
    var intGain: Double { get }
    var moveSpeed: Int { get }
    
    func getIconFullUrl() -> String
    func getImageFullUrl() -> String
    func getPrimaryAttribute() -> HeroAttributeType
}

extension HeroProtocol {
    func getIconFullUrl() -> String {
        return openDotaUrl + icon
    }
    
    func getImageFullUrl() -> String {
        return openDotaUrl + img
    }
    
    func getPrimaryAttribute() -> HeroAttributeType {
        return HeroAttributeType.get(identifier: primaryAttr)
    }
}

struct Hero: Decodable, HeroProtocol {
    var id: Int
    var name: String
    var localizedName: String
    var primaryAttr: String
    var attackType: String
    var roles: [String]
    var img: String // only the path url (need base url)
    var icon: String // only the path url (need base url)
    var baseHealth: Int
    var baseMana: Int
    var baseAttackMax: Int
    var baseStr: Int
    var baseAgi: Int
    var baseInt: Int
    var strGain: Double
    var agiGain: Double
    var intGain: Double
    var moveSpeed: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case localizedName = "localized_name"
        case primaryAttr = "primary_attr"
        case attackType = "attack_type"
        case roles
        case img
        case icon
        case baseHealth = "base_health"
        case baseMana = "base_mana"
        case baseAttackMax = "base_attack_max"
        case baseStr = "base_str"
        case baseAgi = "base_agi"
        case baseInt = "base_int"
        case strGain = "str_gain"
        case agiGain = "agi_gain"
        case intGain = "int_gain"
        case moveSpeed = "move_speed"
    }
}

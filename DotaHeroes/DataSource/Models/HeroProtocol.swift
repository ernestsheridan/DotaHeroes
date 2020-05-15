//
//  HeroProtocol.swift
//  DotaHeroes
//
//  Created by Ernest Sheridan on 15/05/20.
//  Copyright © 2020 Ernest Sheridan. All rights reserved.
//

import Foundation

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

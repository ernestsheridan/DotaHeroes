//
//  HeroRealmModel.swift
//  DotaHeroes
//
//  Created by Ernest Sheridan on 14/05/20.
//  Copyright © 2020 Ernest Sheridan. All rights reserved.
//

import RealmSwift

@objc class HeroRealmModel: Object, HeroProtocol {
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var localizedName: String = ""
    @objc dynamic var primaryAttr: String = ""
    @objc dynamic var attackType: String = ""
    @objc dynamic var img: String = ""
    @objc dynamic var icon: String = ""
    @objc dynamic var baseHealth: Int = 0
    @objc dynamic var baseMana: Int = 0
    @objc dynamic var baseAttackMax: Int = 0
    @objc dynamic var baseStr: Int = 0
    @objc dynamic var baseAgi: Int = 0
    @objc dynamic var baseInt: Int = 0
    @objc dynamic var strGain: Double = 0
    @objc dynamic var agiGain: Double = 0
    @objc dynamic var intGain: Double = 0
    @objc dynamic var moveSpeed: Int = 0
    var roleList: List<String> = List()
    var roles: [String] {
        Array(roleList)
    }
    
    override public static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(hero: HeroProtocol) {
        self.init()
        id = hero.id
        name = hero.name
        localizedName = hero.localizedName
        primaryAttr = hero.primaryAttr
        attackType = hero.attackType
        img = hero.img
        icon = hero.icon
        baseHealth = hero.baseHealth
        baseAttackMax = hero.baseAttackMax
        baseStr = hero.baseStr
        baseAgi = hero.baseAgi
        baseInt = hero.baseInt
        strGain = hero.strGain
        agiGain = hero.agiGain
        intGain = hero.intGain
        moveSpeed = hero.moveSpeed
        
        for role in hero.roles {
            roleList.append(role)
        }
    }
}

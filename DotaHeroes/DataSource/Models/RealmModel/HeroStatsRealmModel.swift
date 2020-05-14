//
//  HeroStatsRealmModel.swift
//  DotaHeroes
//
//  Created by Ernest Sheridan on 14/05/20.
//  Copyright © 2020 Ernest Sheridan. All rights reserved.
//

import RealmSwift

class HerosStatsRealmModel: Object {
    @objc dynamic var objectKey = "heroStatsObjectKey"
    var heroes: List<HeroRealmModel> = List()
    
    override public static func primaryKey() -> String? {
        return "objectKey"
    }
    
    convenience init(heroes: [HeroProtocol]) {
        self.init()
        
        for hero in heroes {
            self.heroes.append(HeroRealmModel(hero: hero))
        }
    }
}

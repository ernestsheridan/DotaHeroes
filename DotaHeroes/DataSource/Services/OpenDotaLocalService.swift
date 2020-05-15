//
//  OpenDotaLocalService.swift
//  DotaHeroes
//
//  Created by Ernest Sheridan on 15/05/20.
//  Copyright © 2020 Ernest Sheridan. All rights reserved.
//

import RxSwift

class OpenDotaLocalService {
    func getHeroStats() -> Observable<[HeroProtocol]> {
        guard let heroStatsData = RealmInstance.shared.realm?.objects(
            HerosStatsRealmModel.self).first else { return Observable.empty() }
        let heroes = Array(heroStatsData.heroes) as [HeroProtocol]
        return Observable.of(heroes)
    }
    
    func setHeroStats(heroes: [HeroProtocol], success: () -> Void, failure: (Error) -> Void) {
        let model = HerosStatsRealmModel(heroes: heroes)
        
        do {
            try RealmInstance.shared.realm?.write({
                RealmInstance.shared.realm?.add(model, update: .modified)
                try RealmInstance.shared.realm?.commitWrite()
                success()
            })
        } catch {
            failure(error)
        }
    }
}

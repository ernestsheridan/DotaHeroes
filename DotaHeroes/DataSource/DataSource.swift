//
//  DataSource.swift
//  DotaHeroes
//
//  Created by Ernest Sheridan on 13/05/20.
//  Copyright © 2020 Ernest Sheridan. All rights reserved.
//

import RxSwift

let openDotaUrl = "https://api.opendota.com"

class DataSource {
    static var shared = DataSource()
    
    // MARK: Services
    
    lazy var openDotaLocalService = OpenDotaLocalService()
    lazy var openDotaApiService = OpenDotaApiService()
    
    // MARK: Functions
    
    func getHeroStats() -> Observable<[HeroProtocol]> {
        let localHeroes = openDotaLocalService.getHeroStats()
        let apiHeroes = openDotaApiService.getHeroStats()
            .do(onNext: { [weak self] response in
                self?.openDotaLocalService.setHeroStats(heroes: response, success: {
                    debugPrint("success save herostats to localdata")
                }) { error in
                    debugPrint("could not save to local data with error: \(error.localizedDescription)")
                }
            })
        
        return Observable.merge(localHeroes.filter({ $0.count > 0 }),
                                apiHeroes.filter({ $0.count > 0 }))
    }
}

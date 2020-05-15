//
//  HeroesCollectionViewModel.swift
//  DotaHeroes
//
//  Created by Ernest Sheridan on 13/05/20.
//  Copyright © 2020 Ernest Sheridan. All rights reserved.
//

import RxSwift

class HeroesCollectionViewModel {
    var heroesCellViewModels: Observable<[HeroesCollectionViewCellModel]>
    
    init(heroes: [HeroProtocol]) {
        let heroesCellViewModels = heroes.map({ hero -> HeroesCollectionViewCellModel in
            HeroesCollectionViewCellModel(id: hero.id,
                                          name: hero.localizedName,
                                          attackType: hero.attackType,
                                          roles: hero.roles,
                                          imageUrl: hero.getImageFullUrl())
        })
        self.heroesCellViewModels = Observable.of(heroesCellViewModels)
    }
}

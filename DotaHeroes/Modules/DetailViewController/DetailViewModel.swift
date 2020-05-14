//
//  DetailViewModel.swift
//  DotaHeroes
//
//  Created by Ernest Sheridan on 14/05/20.
//  Copyright © 2020 Ernest Sheridan. All rights reserved.
//

import RxSwift

class DetailViewModel {
    struct Input {
        var didTapFirstButton: Observable<Void>
        var didTapSecondButton: Observable<Void>
        var didTapThirdButton: Observable<Void>
    }
    
    struct Output {
        var hero: Observable<HeroProtocol>
        var heroRecommendations: Observable<[HeroProtocol]>
        var openHeroDetail: Observable<(HeroProtocol?, HeroRecommendationDict?)>
    }
    
    var hero: HeroProtocol
    var heroRecommendations: [HeroProtocol]
    var allHeroRecommendation: HeroRecommendationDict
    
    init(hero: HeroProtocol, heroRecommendation: HeroRecommendationDict) {
        self.hero = hero
        self.heroRecommendations = heroRecommendation[hero.getPrimaryAttribute()]?.filter({ $0.id != hero.id }) ?? []
        self.allHeroRecommendation = heroRecommendation
    }
    
    func transform(input: Input) -> Output {
        let firstRecommedationHeroTapped = input.didTapFirstButton.map({ [weak self] _ in
            self?.heroRecommendations[safe: 0]
        })
        let secondRecommendationTapped = input.didTapSecondButton.map({ [weak self] _ in
            self?.heroRecommendations[safe: 1]
        })
        let thirdRecommedationHeroTapped = input.didTapThirdButton.map({ [weak self] _ in
            self?.heroRecommendations[safe: 2]
        })
        let didTapRecommendationButton = Observable.merge(firstRecommedationHeroTapped,
                                                          secondRecommendationTapped,
                                                          thirdRecommedationHeroTapped)
        
        let openHeroDetail = didTapRecommendationButton
            .map { [weak self] hero -> (HeroProtocol?, HeroRecommendationDict?) in
                return (hero, self?.allHeroRecommendation)
            }
        return Output(hero: Observable.of(hero),
                      heroRecommendations: Observable.of(heroRecommendations),
                      openHeroDetail: openHeroDetail)
    }
}

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
        var openHeroDetail: Observable<(HeroProtocol?, [HeroProtocol])>
    }
    
    var hero: HeroProtocol
    var heroRecommendations: [HeroProtocol] = []
    var heroes: [HeroProtocol]
    
    init(hero: HeroProtocol, heroes: [HeroProtocol]) {
        self.hero = hero
        self.heroes = heroes
        self.heroRecommendations = getHeroRecommendation(for: hero, from: heroes)
    }
    
    private func getHeroRecommendation(for hero: HeroProtocol, from heroes: [HeroProtocol]) -> [HeroProtocol] {
        var heroRecommendation: ArraySlice<HeroProtocol>
        
        let filteredHeroes = heroes.filter { heroItem -> Bool in
            if hero.id == heroItem.id { return false }
            let sameAttribute = heroItem.primaryAttr == hero.primaryAttr
            let sameRoles = heroItem.roles.first(where: { hero.roles.contains($0) }) != nil
            return sameAttribute && sameRoles
        }
        
        switch hero.getPrimaryAttribute() {
        case .agility:
            heroRecommendation = filteredHeroes.sorted { (firstHero, secondHero) -> Bool in
                firstHero.moveSpeed > secondHero.moveSpeed
            }.prefix(3)
        case .intelligence:
            heroRecommendation = filteredHeroes.sorted { (firstHero, secondHero) -> Bool in
                firstHero.baseMana > secondHero.baseMana
            }.prefix(3)
        default:
            heroRecommendation = filteredHeroes.sorted { (firstHero, secondHero) -> Bool in
                firstHero.baseAttackMax > secondHero.baseAttackMax
            }.prefix(3)
        }
        
        return Array(heroRecommendation)
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
            .map { [weak self] hero -> (HeroProtocol?, [HeroProtocol]) in
                return (hero, self?.heroes ?? [])
            }
        return Output(hero: Observable.of(hero),
                      heroRecommendations: Observable.of(heroRecommendations),
                      openHeroDetail: openHeroDetail)
    }
}

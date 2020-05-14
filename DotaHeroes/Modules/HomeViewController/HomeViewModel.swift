//
//  HomeViewModel.swift
//  DotaHeroes
//
//  Created by Ernest Sheridan on 13/05/20.
//  Copyright © 2020 Ernest Sheridan. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

typealias HeroRecommendationDict = [HeroAttributeType: [HeroProtocol]]

class HomeViewModel {
    
    enum ViewState {
        case loading
        case error(description: String)
        case normal
    }
    
    struct Input {
        var filterSelected: Observable<FilterItemCellModel>
        var heroCellSelected: Observable<HeroesCollectionViewCellModel>
        var retrySelected: Observable<Void>
    }
    
    struct Output {
        var title: Driver<String>
        var viewState: Driver<ViewState>
        var heroes: Driver<[HeroProtocol]>
        var filterItemCellModels: Driver<[FilterItemCellModel]>
        var openDetailHero: Driver<(hero: HeroProtocol?, heroRecommendation: HeroRecommendationDict)>
    }
    
    // MARK: Variables
    
    var heroRecommendation: HeroRecommendationDict? = nil
    
    // MARK: Functions
    
    func transform(_ input: Input) -> Output {
        var roles: [String: Bool] = [:]
        let error = PublishSubject<Error?>()
        let allFilter = FilterItemCellModel(title: "All")
        let selectedFilter = input.filterSelected.startWith(allFilter)
        let title = selectedFilter.map({ $0.title }).asDriver(onErrorJustReturn: "")
        let heroes = input.retrySelected.startWith(())
            .flatMapLatest { _ -> Observable<[HeroProtocol]> in
                DataSource.shared.getHeroStats().share(replay: 1, scope: .whileConnected)
                .do(onNext: { _ in
                    error.onNext(nil)
                }).catchError { err -> Observable<[HeroProtocol]> in
                    error.onNext(err)
                    return Observable.empty()
                }
        }
            
            
    
        let filteredHeroes = Observable
            .combineLatest(heroes.asObservable(), selectedFilter)
            .map({ [weak self] (heroes, filterItemCellModel) -> [HeroProtocol] in
                if filterItemCellModel === allFilter {
                    return heroes
                }
                return self?.filterHeroes(roleId: filterItemCellModel.id, heroes: heroes) ?? []
            })
        
        let filterItemCellModels = heroes
            .do(onNext: { _ in
                roles = [:]
            }).map { heroes -> [FilterItemCellModel] in
                var cellModels = heroes.flatMap({ $0.roles.map({ FilterItemCellModel(title: $0) }) })
                    .filter({ cellModel -> Bool in
                        if roles[cellModel.title] == true {
                            return false
                        } else {
                            roles[cellModel.title] = true
                            return true
                        }
                    })
                cellModels.insert(allFilter, at: 0)
            
                return cellModels
            }.asDriver(onErrorJustReturn: [])
        
        let viewState = error.map { error -> ViewState in
            if let error = error {
                return .error(description: error.localizedDescription)
            } else {
                return .normal
            }
        }
            
        let openDetailHero = input.heroCellSelected.withLatestFrom(heroes) { ($0, $1) }
            .map({ [weak self] (cell, heroes) -> (hero: HeroProtocol?, heroRecommendation: HeroRecommendationDict) in
                guard let self = self else { return (nil, [:]) }
                let hero = heroes.first(where: { $0.id == cell.id })
                let heroRecommendation = self.getHeroRecommendation(heroes: heroes)
                return (hero, heroRecommendation)
            }).asDriver { _ in Driver.empty() }
        
        return Output(title: title,
                      viewState: viewState.asDriver(onErrorJustReturn: .error(description: "")),
                      heroes: filteredHeroes.asDriver(onErrorJustReturn: []),
                      filterItemCellModels: filterItemCellModels,
                      openDetailHero: openDetailHero)
    }
    
    private func filterHeroes(roleId: String, heroes: [HeroProtocol]) -> [HeroProtocol] {
        return heroes.filter({ $0.roles.contains(roleId) })
    }
    
    private func getHeroRecommendation(heroes: [HeroProtocol]) -> HeroRecommendationDict {
        if let heroRecommendation = heroRecommendation {
            return heroRecommendation
        }
        
        var heroRecommendation: HeroRecommendationDict = [:]
        
        let agiRecommendation = heroes.sorted { (firstHero, secondHero) -> Bool in
            firstHero.moveSpeed > secondHero.moveSpeed
        }.prefix(4)
        
        let strengthRecommendation = heroes.sorted { (firstHero, secondHero) -> Bool in
            firstHero.baseAttackMax > secondHero.baseAttackMax
        }.prefix(4)
        
        let intRecommendation = heroes.sorted { (firstHero, secondHero) -> Bool in
            firstHero.baseMana > secondHero.baseMana
        }.prefix(4)
        
        heroRecommendation[.agility] = Array(agiRecommendation)
        heroRecommendation[.strength] = Array(strengthRecommendation)
        heroRecommendation[.intelligence] = Array(intRecommendation)
        
        self.heroRecommendation = heroRecommendation
        
        return heroRecommendation
    }
}

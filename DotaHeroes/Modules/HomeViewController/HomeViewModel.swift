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
        var heroesCollectionViewModel: Driver<HeroesCollectionViewModel>
        var filterItemCellModels: Driver<[FilterItemCellModel]>
        var openDetailHero: Driver<(hero: HeroProtocol?, heroes: [HeroProtocol])>
    }
    
    // MARK: Functions
    
    func transform(_ input: Input) -> Output {
        var roles: [String: Bool] = [:]
        let isLoading = BehaviorSubject<Bool>(value: false)
        let error = PublishSubject<Error?>()
        let allFilter = FilterItemCellModel(title: "All")
        let selectedFilter = input.filterSelected.startWith(allFilter)
        let title = selectedFilter.map({ $0.title }).asDriver(onErrorJustReturn: "")
        let heroes = input.retrySelected.startWith(())
            .do(onNext: { isLoading.onNext(true) })
            .flatMapLatest { _ -> Observable<[HeroProtocol]> in
                DataSource.shared.getHeroStats().share(replay: 1, scope: .whileConnected)
                .do(onNext: { _ in
                    isLoading.onNext(false)
                    error.onNext(nil)
                }).catchError { err -> Observable<[HeroProtocol]> in
                    isLoading.onNext(false)
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
        
        let heroesCollectionViewModel = filteredHeroes.map { heroes -> HeroesCollectionViewModel in
            return HeroesCollectionViewModel(heroes: heroes)
        }.asDriver(onErrorRecover: { _ in Driver.empty() })
        
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
        
        let viewState = Observable.combineLatest(isLoading.asObservable(), error.asObservable())
            .map { isLoading, error -> ViewState in
                if isLoading {
                    return .loading
                } else if let error = error {
                    return .error(description: error.localizedDescription)
                } else {
                    return .normal
                }
        }
            
        let openDetailHero = input.heroCellSelected.withLatestFrom(heroes) { ($0, $1) }
            .map({ (cell, heroes) -> (hero: HeroProtocol?, heroes: [HeroProtocol]) in
                let hero = heroes.first(where: { $0.id == cell.id })
                return (hero, heroes)
            }).asDriver { _ in Driver.empty() }
        
        return Output(title: title,
                      viewState: viewState.asDriver(onErrorJustReturn: .error(description: "")),
                      heroesCollectionViewModel: heroesCollectionViewModel,
                      filterItemCellModels: filterItemCellModels,
                      openDetailHero: openDetailHero)
    }
    
    private func filterHeroes(roleId: String, heroes: [HeroProtocol]) -> [HeroProtocol] {
        return heroes.filter({ $0.roles.contains(roleId) })
    }
}

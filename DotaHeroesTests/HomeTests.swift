//
//  HomeTests.swift
//  DotaHeroesTests
//
//  Created by Ernest Sheridan on 15/05/20.
//  Copyright © 2020 Ernest Sheridan. All rights reserved.
//

import XCTest

import RxSwift
@testable import DotaHeroes

class HomeTests: XCTestCase {

    var homeViewModel: HomeViewModel!
    var disposeBag = DisposeBag()
    
    override func setUp() {
        homeViewModel = HomeViewModel()
    }

    override func tearDown() {
        disposeBag = DisposeBag()
    }
    
    func testParseData() {
        let expect = expectation(description: "Test Parse Codable Data")
        
        DataSource.shared.openDotaApiService
            .getHeroStats()
            .filter({ $0.count > 0 })
            .subscribe(onNext: { heroes in
                expect.fulfill()
            }, onError: { error in
                XCTFail(error.localizedDescription)
            }).disposed(by: disposeBag)
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testFilterSelected() {
        let expect = expectation(description: "Test Select Filter Hero Roles")
        expect.expectedFulfillmentCount = 2
        
        let filter = FilterItemCellModel(title: "Carry")
        let filterSelected = PublishSubject<FilterItemCellModel>()
        let output = homeViewModel.transform(HomeViewModel.Input(filterSelected: filterSelected.asObservable(),
                                                                 heroCellSelected: Observable.empty(),
                                                                 retrySelected: Observable.empty()))
        output.title
            .skip(1)
            .drive(onNext: { title in
                if title == filter.title {
                    expect.fulfill()
                } else {
                    XCTFail("Wrong title: \(title)")
                }
            }).disposed(by: disposeBag)
        
        output.heroesCollectionViewModel
            .asObservable()
            .skip(1)
            .flatMapLatest({ return $0.heroesCellViewModels })
            .subscribe(onNext: { cells in
                let allSatisfy = cells.allSatisfy { cell -> Bool in
                    cell.description.contains(filter.title)
                }
                if allSatisfy {
                    expect.fulfill()
                } else {
                    XCTFail("Hero not filtered properly")
                }
            }).disposed(by: disposeBag)
        
        filterSelected.onNext(filter)
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testHeroSelected() {
        let expect = expectation(description: "Test Select Hero")
        expect.expectedFulfillmentCount = 2
        let heroCellSelected = PublishSubject<HeroesCollectionViewCellModel>()
        let output = homeViewModel.transform(HomeViewModel.Input(filterSelected: Observable.empty(),
                                                                 heroCellSelected: heroCellSelected,
                                                                 retrySelected: Observable.empty()))
        var selectedHeroId: Int = -1
        
        output.openDetailHero
            .drive(onNext:{ (hero, heroes) in
                if heroes.count > 0 {
                    expect.fulfill()
                }
                
                if hero?.id == selectedHeroId {
                    expect.fulfill()
                }
            }).disposed(by: disposeBag)
        
        output.heroesCollectionViewModel
            .asObservable()
            .flatMapLatest({ $0.heroesCellViewModels }).subscribe(onNext: { cells in
                guard let cell = cells.last else { return }
                selectedHeroId = cell.id
                heroCellSelected.onNext(cell)
            }).disposed(by: disposeBag)
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testRetry() {
        let expect = expectation(description: "Test Retry Call API, Expect only triggered 1 time each")
        expect.expectedFulfillmentCount = 2
        let retrySelected = PublishSubject<Void>()
        let output = homeViewModel.transform(HomeViewModel.Input(filterSelected: Observable.empty(),
                                                                 heroCellSelected: Observable.empty(),
                                                                 retrySelected: retrySelected))
        
        output.heroesCollectionViewModel.asObservable()
            .skip(2) // Triggered by localdata and api
            .subscribe(onNext: { _ in
                expect.fulfill()
            }).disposed(by: disposeBag)
        
        retrySelected.onNext(())
        retrySelected.onNext(())
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
}

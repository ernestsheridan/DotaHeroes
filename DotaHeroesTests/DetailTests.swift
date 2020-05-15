//
//  DetailTests.swift
//  DotaHeroesTests
//
//  Created by Ernest Sheridan on 15/05/20.
//  Copyright © 2020 Ernest Sheridan. All rights reserved.
//

import XCTest
import RxSwift
@testable import DotaHeroes

class DetailTests: XCTestCase {

    var viewModel: DetailViewModel!
    var disposeBag = DisposeBag()
    
    override func setUp() {
        DataSource.shared.getHeroStats().subscribe(onNext: { [weak self] heroes in
            self?.viewModel = DetailViewModel(hero: heroes.last!, heroes: heroes)
        }).disposed(by: disposeBag)
    }

    override func tearDown() {
        disposeBag = DisposeBag()
    }
    
    
    /// Test Hero Recommendation Attribute & Roles match with the Hero
    func testHeroRecommendation() {
        let hero = viewModel.hero
        let trueRecommendations = viewModel.heroRecommendations.allSatisfy({ recommendedHero in
            let sameRole = recommendedHero.roles.first(where: { role -> Bool in
                hero.roles.contains(role)
            }) != nil
            let sameAttribute = hero.primaryAttr == recommendedHero.primaryAttr
            
            return sameRole && sameAttribute
        })
        
        XCTAssert(trueRecommendations)
    }

    func testTapFirstRecomendation() {
        let expect = expectation(description: "Open heroRecommendations[0]")
        let buttonTapped = PublishSubject<Void>()
        let firstRecommendedHero = viewModel.heroRecommendations.first!
        let output = viewModel.transform(input: DetailViewModel.Input(didTapFirstButton: buttonTapped,
                                                         didTapSecondButton: Observable.empty(),
                                                         didTapThirdButton: Observable.empty()))
        
        output.openHeroDetail.subscribe(onNext: { (hero, heroes) in
            if hero?.id == firstRecommendedHero.id {
                expect.fulfill()
            }
        }).disposed(by: disposeBag)
        
        buttonTapped.onNext(())
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testTapSecondRecommendation() {
        let expect = expectation(description: "Open heroRecommendations[1]")
        let buttonTapped = PublishSubject<Void>()
        let secondRecommendedHero = viewModel.heroRecommendations[1]
        let output = viewModel.transform(input: DetailViewModel.Input(didTapFirstButton: Observable.empty(),
                                                         didTapSecondButton: buttonTapped,
                                                         didTapThirdButton: Observable.empty()))
       
        output.openHeroDetail.subscribe(onNext: { (hero, heroes) in
            if hero?.id == secondRecommendedHero.id {
                expect.fulfill()
            }
        }).disposed(by: disposeBag)
        
        buttonTapped.onNext(())
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testTapThirdRecommendation() {
        let expect = expectation(description: "Open heroRecommendations[2]")
        let buttonTapped = PublishSubject<Void>()
        let thirdRecommendedHero = viewModel.heroRecommendations[2]
        let output = viewModel.transform(input: DetailViewModel.Input(didTapFirstButton: Observable.empty(),
                                                         didTapSecondButton: Observable.empty(),
                                                         didTapThirdButton: buttonTapped))
        
        output.openHeroDetail.subscribe(onNext: { (hero, heroes) in
            if hero?.id == thirdRecommendedHero.id {
                expect.fulfill()
            }
        }).disposed(by: disposeBag)
        
        buttonTapped.onNext(())
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }

}

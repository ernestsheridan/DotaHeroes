//
//  DotaHeroesTests.swift
//  DotaHeroesTests
//
//  Created by Ernest Sheridan on 13/05/20.
//  Copyright © 2020 Ernest Sheridan. All rights reserved.
//

import XCTest
import RxSwift
@testable import DotaHeroes

class DotaHeroesTests: XCTestCase {

    var openDotaService: OpenDotaService!
    var disposeBag = DisposeBag()
    
    override func setUp() {
        openDotaService = OpenDotaService()
    }

    override func tearDown() {
        disposeBag = DisposeBag()
    }

    func testParseHeroStatsApi() {
        
    }
}

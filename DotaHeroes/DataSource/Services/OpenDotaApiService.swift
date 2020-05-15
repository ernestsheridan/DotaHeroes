//
//  OpenDotaApiService.swift
//  DotaHeroes
//
//  Created by Ernest Sheridan on 15/05/20.
//  Copyright © 2020 Ernest Sheridan. All rights reserved.
//

import RxSwift
import Moya

class OpenDotaApiService {
    let openDotaProvider: MoyaProvider<OpenDota> = MoyaProvider(plugins: [NetworkLoggerPlugin()])
    
    func getHeroStats() -> Observable<[HeroProtocol]> {
        let apiResponse = openDotaProvider.rx.request(.heroStat)
            .asObservable()
            .localizeErrorResponse()
            .map([Hero].self)
            .map({ $0 as [HeroProtocol] })
            
        return apiResponse
    }
}

public extension ObservableType where Element == Response {
    func localizeErrorResponse() -> Observable<Element> {
        return self.catchError({ (error) -> Observable<Response> in
            return Observable.error(ErrorHelper.shared.getError(error: error))
        })
    }
}

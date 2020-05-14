//
//  DataSource.swift
//  DotaHeroes
//
//  Created by Ernest Sheridan on 13/05/20.
//  Copyright © 2020 Ernest Sheridan. All rights reserved.
//

import Foundation
import RxSwift
import Moya

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

class OpenDotaLocalService {
    func getHeroStats() -> Observable<[HeroProtocol]> {
        guard let heroStatsData = RealmInstance.shared.realm?.objects(
            HerosStatsRealmModel.self).first else { return Observable.empty() }
        let heroes = Array(heroStatsData.heroes) as [HeroProtocol]
        return Observable.of(heroes)
    }
    
    func setHeroStats(heroes: [HeroProtocol], success: () -> Void, failure: (Error) -> Void) {
        let model = HerosStatsRealmModel(heroes: heroes)
        
        do {
            try RealmInstance.shared.realm?.write({
                RealmInstance.shared.realm?.add(model, update: .modified)
                try RealmInstance.shared.realm?.commitWrite()
                success()
            })
        } catch {
            failure(error)
        }
    }
}

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

class ErrorHelper {
    static var shared = ErrorHelper()
    
    var noInternetMessage = "The Internet connection appears to be offline"
    var unstableConnectionMessage = "Unstable Internet connection"
    var notFoundMessage = "The data you're searching can't be found"
    var generalErrorMessage = "Server error, Please try again"
    
    // Get Error with given Error
    @objc public func getError(error: Swift.Error) -> NSError {
        var errorCode = (error as NSError).code
        
        if let err = error as? MoyaError {
            switch err {
            case .underlying(let moyaError):
                errorCode = (moyaError.0 as NSError).code
            default:
                debugPrint("Error Uncaught")
            }
        }
        
        switch errorCode {
        case NSURLErrorNotConnectedToInternet, 13:
            return self.getError(message: noInternetMessage, code: errorCode)
        case NSURLErrorTimedOut, NSURLErrorNetworkConnectionLost:
            return self.getError(message: unstableConnectionMessage, code: errorCode)
            
        case 412:
            return error as NSError
        case 404:
            return self.getError(message: notFoundMessage, code: errorCode)
            
        default:
            return self.getError(message: generalErrorMessage, code: errorCode)
        }
    }
    
    // Get Error With Code and Message
    @objc public func getError(message: String, code: NSInteger = 400) -> NSError {
        return NSError(domain: "com.network-reponse.error", code: code, userInfo: [NSLocalizedDescriptionKey: message])
    }
    
}

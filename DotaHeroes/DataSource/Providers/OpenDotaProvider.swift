//
//  OpenDotaProvider.swift
//  DotaHeroes
//
//  Created by Ernest Sheridan on 13/05/20.
//  Copyright © 2020 Ernest Sheridan. All rights reserved.
//

import Moya
import RxSwift

enum OpenDota {
    case heroStat
}

extension OpenDota: TargetType {
    public var baseURL: URL { URL(string: openDotaUrl + "/api")! }
    
    public var path: String {
        switch self {
        case .heroStat:
            return "/herostats"
        }
    }
    
    public var method: Moya.Method {
        return .get
    }
    
    public var sampleData: Data {
        return Data()
    }
    
    public var task: Task {
        switch method {
        case .get:
            return .requestPlain
        default:
            return .requestPlain
        }
    }
    
    public var headers: [String : String]? {
        return nil
    }
}

//
//  ErrorHelper.swift
//  DotaHeroes
//
//  Created by Ernest Sheridan on 14/05/20.
//  Copyright © 2020 Ernest Sheridan. All rights reserved.
//

import Moya

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

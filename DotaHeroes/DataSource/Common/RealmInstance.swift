//
//  RealmInstance.swift
//  DotaHeroes
//
//  Created by Ernest Sheridan on 14/05/20.
//  Copyright © 2020 Ernest Sheridan. All rights reserved.
//

import RealmSwift

public class RealmInstance {
    
    // Mark: Variables
    
    public static let shared: RealmInstance = RealmInstance()
    private var realmInternal: Realm?
    var realm: Realm? {
        if realmInternal == nil {
            instantiateRealm()
        }
        return realmInternal
    }
    
    required public init() {
        
    }
    
    private func instantiateRealm() {
        let configuration = Realm.Configuration(schemaVersion: 0)
        
        print ("Realm Initialization starting...")
        
        do {
            self.realmInternal = try Realm(configuration: configuration)
            print ("Realm Instance created")
        } catch {
            print ("Realm Instantiation Error: \(error)")
        }
    }
}

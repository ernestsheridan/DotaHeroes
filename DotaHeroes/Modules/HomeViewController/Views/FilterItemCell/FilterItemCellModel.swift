//
//  FilterItemCellModel.swift
//  DotaHeroes
//
//  Created by Ernest Sheridan on 13/05/20.
//  Copyright © 2020 Ernest Sheridan. All rights reserved.
//

import Foundation

class FilterItemCellModel {
    var id: String = ""
    var title: String = ""
    
    init(title: String) {
        self.id = title
        self.title = title
    }
}

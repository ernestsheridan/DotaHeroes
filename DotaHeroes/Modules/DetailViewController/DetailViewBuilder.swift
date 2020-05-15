//
//  DetailViewBuilder.swift
//  DotaHeroes
//
//  Created by Ernest Sheridan on 14/05/20.
//  Copyright © 2020 Ernest Sheridan. All rights reserved.
//

import UIKit

class DetailViewBuilder {
    
    var detailViewController: DetailViewController?
    
    func build(hero: HeroProtocol, heroes: [HeroProtocol]) {
        guard let detailViewController = UIStoryboard(name: "DetailViewController", bundle: nil)
            .instantiateInitialViewController() as? DetailViewController else { return }
        let viewModel = DetailViewModel(hero: hero, heroes: heroes)
        detailViewController.viewModel = viewModel
        self.detailViewController = detailViewController
    }
}

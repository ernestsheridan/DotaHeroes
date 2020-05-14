//
//  DetailViewController.swift
//  DotaHeroes
//
//  Created by Ernest Sheridan on 14/05/20.
//  Copyright © 2020 Ernest Sheridan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class DetailViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var strengthLabel: UILabel!
    @IBOutlet weak var agilityLabel: UILabel!
    @IBOutlet weak var intelligenceLabel: UILabel!
    @IBOutlet weak var healthLabel: UILabel!
    @IBOutlet weak var maxAttackLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var recommendationFirst: UIButton!
    @IBOutlet weak var recommendationSecond: UIButton!
    @IBOutlet weak var recommendationThird: UIButton!
    
    // MARK: Variables
    
    var viewModel: DetailViewModel?
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRx()
    }
    
    private func setupRx() {
        guard let output = viewModel?.transform(input: DetailViewModel.Input(
            didTapFirstButton: recommendationFirst.rx.tap.asObservable(),
            didTapSecondButton: recommendationSecond.rx.tap.asObservable(),
            didTapThirdButton: recommendationThird.rx.tap.asObservable())) else { return }
        
        output.hero
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] hero in
                self?.title = hero.localizedName
                self?.setupHeroUI(hero)
            }).disposed(by: disposeBag)
        
        output.heroRecommendations
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] heroRecommendations in
                guard let self = self,
                    heroRecommendations.count >= 3 else {
                    return
                }
                let firstRecommendation = heroRecommendations[0]
                let secondRecommendation = heroRecommendations[1]
                let thirdRecommendation = heroRecommendations[2]
                self.recommendationFirst.setTitle(firstRecommendation.localizedName, for: .normal)
                self.recommendationSecond.setTitle(secondRecommendation.localizedName, for: .normal)
                self.recommendationThird.setTitle(thirdRecommendation.localizedName, for: .normal)
                self.recommendationFirst.kf.setImage(with: URL(string: firstRecommendation.getIconFullUrl()), for: .normal)
                self.recommendationSecond.kf.setImage(with: URL(string: secondRecommendation.getIconFullUrl()), for: .normal)
                self.recommendationThird.kf.setImage(with: URL(string: thirdRecommendation.getIconFullUrl()), for: .normal)
            }).disposed(by: disposeBag)
        
        output.openHeroDetail
            .asDriver { _ in Driver.empty() }
            .drive(onNext: { [weak self] (hero, heroRecommendations) in
                guard let hero = hero, let heroRecommendations = heroRecommendations else { return }
                self?.openHero(hero, heroRecommendation: heroRecommendations)
            }).disposed(by: disposeBag)
    }
    
    private func setupHeroUI(_ hero: HeroProtocol) {
        imageView.kf.setImage(with: URL(string: hero.getImageFullUrl()))
        titleLabel.text = hero.localizedName
        subtitleLabel.text = hero.attackType
        descriptionLabel.text = hero.roles.joined(separator: ", ")
        strengthLabel.text = "\(hero.baseStr) +(\(hero.strGain))"
        agilityLabel.text = "\(hero.baseAgi) +(\(hero.agiGain))"
        intelligenceLabel.text = "\(hero.baseInt) +(\(hero.intGain))"
        healthLabel.text = "\(hero.baseHealth)"
        maxAttackLabel.text = "\(hero.baseAttackMax)"
        speedLabel.text = "\(hero.moveSpeed)"
    }
    
    private func openHero(_ hero: HeroProtocol, heroRecommendation: HeroRecommendationDict) {
        let builder = DetailViewBuilder()
        builder.build(hero: hero, heroRecommendation: heroRecommendation)
        guard let viewController = builder.detailViewController else { return }
        navigationController?.pushViewController(viewController, animated: true)
    }
}

public extension Array {
    subscript (safe index: Int) -> Element? {
        return index < count ? self[index] : nil
    }
}

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
    @IBOutlet var seeMoreSectionHeightConstraint: NSLayoutConstraint!
    
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
                let seeMoreHeightConstraint = self?.seeMoreSectionHeightConstraint
                guard let self = self, heroRecommendations.count >= 3 else {
                    seeMoreHeightConstraint?.isActive = true
                    return
                }
                seeMoreHeightConstraint?.isActive = false
                self.recommendationFirst.setTitle(heroRecommendations[0].localizedName, for: .normal)
                self.recommendationSecond.setTitle(heroRecommendations[1].localizedName, for: .normal)
                self.recommendationThird.setTitle(heroRecommendations[2].localizedName, for: .normal)
                self.recommendationFirst.kf
                    .setImage(with: URL(string: heroRecommendations[0].getIconFullUrl()), for: .normal)
                self.recommendationSecond.kf
                    .setImage(with: URL(string: heroRecommendations[1].getIconFullUrl()), for: .normal)
                self.recommendationThird.kf
                    .setImage(with: URL(string: heroRecommendations[2].getIconFullUrl()), for: .normal)
            }).disposed(by: disposeBag)
        
        output.openHeroDetail
            .asDriver { _ in Driver.empty() }
            .drive(onNext: { [weak self] (hero, heroes) in
                guard let hero = hero, heroes.count >= 3  else { return }
                self?.openHero(hero, heroes: heroes)
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
    
    private func openHero(_ hero: HeroProtocol, heroes: [HeroProtocol]) {
        let builder = DetailViewBuilder()
        builder.build(hero: hero, heroes: heroes)
        guard let viewController = builder.detailViewController else { return }
        navigationController?.pushViewController(viewController, animated: true)
    }
}

//
//  HomeViewController.swift
//  DotaHeroes
//
//  Created by Ernest Sheridan on 13/05/20.
//  Copyright © 2020 Ernest Sheridan. All rights reserved.
//

import UIKit
import RxSwift

class HomeViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var retryButton: UIButton!
    @IBOutlet weak var errorContainer: UIView!
    @IBOutlet weak var errorHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: HeroesCollectionView!
    
    
    // MARK: Variables
    
    var viewModel: HomeViewModel?
    var disposeBag = DisposeBag()
    
    // MARK: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupRx()
    }
    
    func setupUI() {
        collectionView.setupUI()
        tableView.delegate = self
        tableView.register(FilterItemCell.nib,
                           forCellReuseIdentifier: FilterItemCell.id)
    }
    
    func setupRx() {
        let output = viewModel?.transform(
            HomeViewModel.Input(
                filterSelected: tableView.rx.modelSelected(FilterItemCellModel.self).asObservable(),
                heroCellSelected: collectionView.rx.modelSelected(HeroesCollectionViewCellModel.self).asObservable(),
                retrySelected: retryButton.rx.tap.asObservable()
            )
        )
        
        output?.title
            .drive(self.rx.title)
            .disposed(by: disposeBag)
        
        output?.heroesCollectionViewModel
            .drive(onNext: { [weak self] viewModel in
                self?.collectionView.viewModel = viewModel
            }).disposed(by: disposeBag)
        
        output?.filterItemCellModels
            .drive(tableView.rx.items(cellIdentifier: FilterItemCell.id,
                                      cellType: FilterItemCell.self))
            { index, cellModel, cell in
                cell.cellModel = cellModel
            }.disposed(by: disposeBag)
        
        output?.filterItemCellModels
            .drive(onNext: { [weak self] _ in
                self?.tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .none)
            }).disposed(by: disposeBag)
        
        output?.viewState
            .drive(onNext: { [weak self] viewState in
                switch viewState {
                case .error(let description):
                    self?.errorLabel.text = description
                    self?.errorContainer.backgroundColor = UIColor.red.withAlphaComponent(0.41)
                    self?.errorHeightConstraint.constant = 48
                    UIView.animate(withDuration: 0.3) {
                        self?.errorContainer.layoutIfNeeded()
                    }
                case .loading:
                    self?.errorLabel.text = "Please Wait"
                    self?.errorContainer.backgroundColor = UIColor.blue.withAlphaComponent(0.41)
                    self?.errorHeightConstraint.constant = 48
                    UIView.animate(withDuration: 0.3) {
                        self?.errorContainer.layoutIfNeeded()
                    }
                case .normal:
                    self?.errorHeightConstraint.constant = 0
                    UIView.animate(withDuration: 0.3) {
                        self?.errorContainer.layoutIfNeeded()
                    }
                }
            }).disposed(by: disposeBag)
        
        output?.openDetailHero
        .drive(onNext: { [weak self] (hero, heroes) in
            guard let hero = hero else { return }
            let builder = DetailViewBuilder()
            builder.build(hero: hero, heroes: heroes)
            guard let controller = builder.detailViewController else { return }
            self?.navigationController?.pushViewController(controller, animated: true)
        }).disposed(by: disposeBag)
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
}

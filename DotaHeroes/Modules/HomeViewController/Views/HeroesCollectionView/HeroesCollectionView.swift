//
//  HeroesCollectionViewCollectionViewController.swift
//  DotaHeroes
//
//  Created by Ernest Sheridan on 13/05/20.
//  Copyright © 2020 Ernest Sheridan. All rights reserved.
//

import UIKit
import RxSwift

class HeroesCollectionView: UICollectionView {
    var disposeBag: DisposeBag!
    var viewModel: HeroesCollectionViewModel? {
        didSet {
            setupRx()
        }
    }
    
    func setupRx() {
        disposeBag = DisposeBag()
        
        viewModel?.heroesCellViewModels
            .asDriver(onErrorJustReturn: [])
            .drive(self.rx.items(cellIdentifier: HeroesCollectionViewCell.id, cellType: HeroesCollectionViewCell.self))
            { index, cellModel, cell in
                cell.viewModel = cellModel
            }.disposed(by: disposeBag)
    }
    
    func setupUI() {
        register(HeroesCollectionViewCell.nib, forCellWithReuseIdentifier: HeroesCollectionViewCell.id)
        delegate = self
//        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
//            let collectionViewContentWidth = UIScreen.main.bounds.width - 32
//            let noSpacingContentWidth = collectionViewContentWidth - 120
//            let width = (noSpacingContentWidth / 3)
//            let height = (width / 16 * 9) + 90
//            layout.itemSize = CGSize(width: width, height: height)
//        }
    }
}

// MARK: UICollectionViewDelegate

extension HeroesCollectionView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewContentWidth = collectionView.bounds.width - 32
        let noSpacingContentWidth = collectionViewContentWidth - 24
        let width = (noSpacingContentWidth / 3)
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let firstLabelHeight = "firstlabel".boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .bold)], context: nil).height
        let secondLabelHeight = "secondlabel".boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)], context: nil).height
        let height = (width / 16 * 9) + firstLabelHeight + (secondLabelHeight * 3) + 36
        
        return CGSize(width: width, height: height)
    }

}

extension String {
    
}

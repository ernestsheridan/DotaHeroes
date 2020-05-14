//
//  HeroesCollectionViewCell.swift
//  DotaHeroes
//
//  Created by Ernest Sheridan on 13/05/20.
//  Copyright © 2020 Ernest Sheridan. All rights reserved.
//

import UIKit
import Kingfisher

class HeroesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    static let id = "HeroesCollectionViewCell"
    static let nib = UINib(nibName: "HeroesCollectionViewCell", bundle: nil)
    
    var viewModel: HeroesCollectionViewCellModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            imageView.kf.setImage(with: viewModel.imageUrl)
            titleLabel.text = viewModel.name
            subtitleLabel.text = viewModel.subtitle
            descriptionLabel.text = viewModel.description
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}

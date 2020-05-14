//
//  FilterItemCell.swift
//  DotaHeroes
//
//  Created by Ernest Sheridan on 13/05/20.
//  Copyright © 2020 Ernest Sheridan. All rights reserved.
//

import UIKit

class FilterItemCell: UITableViewCell {

    // MARK: Outlets
    
    @IBOutlet weak var titleLabel: UILabel!

    // MARK: Variables
    
    static let id = "FilterItemCell"
    static let nib = UINib(nibName: "FilterItemCell", bundle: nil)
    
    var cellModel: FilterItemCellModel? {
        didSet {
            titleLabel.text = cellModel?.title
        }
    }
    
    // MARK: Functions
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

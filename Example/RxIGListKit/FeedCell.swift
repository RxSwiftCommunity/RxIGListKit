//
//  FeedCell.swift
//  RxIGListKit_Example
//
//  Created by Bruce-pac on 2019/3/24.
//  Copyright © 2019 RxSwiftCommunity. All rights reserved.
//

import UIKit

class FeedCell: UICollectionViewCell {

    @IBOutlet weak var label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func bindViewModel(model: Feed) {
        label.text = model.name
    }

}

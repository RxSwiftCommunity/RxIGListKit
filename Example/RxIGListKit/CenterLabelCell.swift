//
//  CenterLabelCell.swift
//  RxIGListKit_Example
//
//  Created by gxy on 2019/3/25.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

class CenterLabelCell: UICollectionViewCell {

    @IBOutlet weak var label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func bindViewModel(model: CenterItem) {
        label.text = model.name
    }
}

//
//  CenterItemSectionController.swift
//  RxIGListKit_Example
//
//  Created by gxy on 2019/3/30.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import IGListKit

class CenterItemSectionController: ListSectionController {
    var object: CenterItem!

    override func numberOfItems() -> Int {
        return 1
    }

    override func sizeForItem(at index: Int) -> CGSize {
        let width: CGFloat! = collectionContext?.containerSize.width
        return CGSize(width: width, height: 40)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(withNibName: "CenterLabelCell", bundle: nil, for: self, at: index) as? CenterLabelCell else { fatalError() }
        cell.bindViewModel(model: object)
        return cell
    }

    override func didUpdate(to object: Any) {
        self.object = object as? CenterItem
    }
}

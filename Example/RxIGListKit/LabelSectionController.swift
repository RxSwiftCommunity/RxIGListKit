//
//  LabelSectionController.swift
//  RxIGListKit_Example
//
//  Created by gxy on 2019/4/4.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import IGListKit

final class LabelSectionController: ListSectionController {

    private var object: String?

    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: 55)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: LabelCell.self, for: self, at: index) as? LabelCell else {
            fatalError()
        }
        cell.text = object
        return cell
    }

    override func didUpdate(to object: Any) {
        self.object = String(describing: object)
    }

}

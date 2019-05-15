//
//  FeedSectionController.swift
//  RxIGListKit_Example
//
//  Created by Bruce-pac on 2019/3/30.
//  Copyright © 2019 RxSwiftCommunity. All rights reserved.
//

import Foundation
import IGListKit

class FeedSectionController: ListSectionController {

    var object: Feed!

    override func numberOfItems() -> Int {
        return 1
    }

    override func sizeForItem(at index: Int) -> CGSize {
        let width: CGFloat! = collectionContext?.containerSize.width
        return CGSize(width: width, height: 40)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(withNibName: "FeedCell", bundle: nil, for: self, at: index) as? FeedCell else { fatalError() }
        cell.bindViewModel(model: object)
        return cell
    }

    override func didUpdate(to object: Any) {
        self.object = object as? Feed
    }

    override func didSelectItem(at index: Int) {
        print("didSelectItem at \(index)")
    }

    override func canMoveItem(at index: Int) -> Bool {
        return true
    }
}

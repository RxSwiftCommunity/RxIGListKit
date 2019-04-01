//
//  CenterItem.swift
//  RxIGListKit_Example
//
//  Created by gxy on 2019/3/25.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import IGListKit

class CenterItem: ListDiffable {
    let name: String
    init(name: String) {
        self.name = name
    }
    func diffIdentifier() -> NSObjectProtocol {
        return name as NSObjectProtocol
    }
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? CenterItem else { return false }
        return name == object.name
    }
}

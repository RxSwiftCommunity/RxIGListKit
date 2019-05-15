//
//  Person.swift
//  RxIGListKit_Example
//
//  Created by Bruce-pac on 2019/4/7.
//  Copyright © 2019 RxSwiftCommunity. All rights reserved.
//

import Foundation
import IGListKit
import RxIGListKit

final class Person: SectionModelDiffable {

    let pk: Int
    let name: String

    init(pk: Int, name: String) {
        self.pk = pk
        self.name = name
    }

    func diffIdentifier() -> NSObjectProtocol {
        return pk as NSNumber
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? Person else { return false }
        return self.name == object.name
    }

}

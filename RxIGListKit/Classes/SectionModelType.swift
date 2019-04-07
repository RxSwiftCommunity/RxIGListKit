//
//  SectionObjectType.swift
//  RxIGListKit
//
//  Created by gxy on 2019/3/30.
//

import Foundation
import IGListKit.IGListDiffable

public protocol SectionModelType {
    associatedtype ObjectType: ListDiffable
    var object: ObjectType { get }
}

public extension SectionModelType where Self: ListDiffable, Self.ObjectType == Self {
    var object: ObjectType {
        return self
    }
}

public typealias SectionModelDiffable = SectionModelType & ListDiffable

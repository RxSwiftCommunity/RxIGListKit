//
//  RxListAdapterDataSourceType.swift
//  RxIGListKit
//
//  Created by gxy on 2019/4/6.
//

import Foundation
import IGListKit.IGListAdapter
import RxSwift

public protocol RxListAdapterDataSourceType: AnyObject {
    associatedtype Element
    func listAdapter(_ adapter: ListAdapter, observedEvent: Event<Element>)
}

//
//  RxListAdapterDataSource.swift
//  RxIGListKit
//
//  Created by gxy on 2019/3/17.
//

import Foundation
import IGListKit
import RxSwift

public typealias SectionModelDiffable = SectionModelType & ListDiffable

public protocol RxListAdapterDataSourceType {
    associatedtype Element
    func listAdapter(_ adapter: ListAdapter, observedEvent: Event<Element>)
}

public final class RxListAdapterDataSource<E: SectionModelType>: NSObject, ListAdapterDataSource {
    public typealias Element = [E]
    var objects: Element = []

    public typealias SectionControllerProvider = (ListAdapter, E) -> ListSectionController
    public typealias EmptyViewProvider = (ListAdapter) -> UIView?
    let sectionControllerProvider: SectionControllerProvider
    let emptyViewProvider: EmptyViewProvider?

    public init(sectionControllerProvider: @escaping SectionControllerProvider,
                emptyViewProvider: EmptyViewProvider?) {
        self.sectionControllerProvider = sectionControllerProvider
        self.emptyViewProvider = emptyViewProvider
    }

    public func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return objects.map { $0.object }
    }

    public func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        let castObj = object as! E.ObjectType
        let temp = objects.filter { (e) -> Bool in
            e.object.diffIdentifier().isEqual(castObj.diffIdentifier())
        }
        guard temp.count == 1 else {
            fatalError("\(type(of: object))'s isEqual(toDiffableObject:) method is not implemented correctly")
        }
        return sectionControllerProvider(listAdapter, temp.first!)
    }

    public func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return emptyViewProvider?(listAdapter)
    }
}

extension RxListAdapterDataSource: RxListAdapterDataSourceType {
    public func listAdapter(_ adapter: ListAdapter, observedEvent: Event<Element>) {
        switch observedEvent {
        case .next(let e):
            objects = e
            adapter.performUpdates(animated: true) { _ in
            }
        default:
            print(observedEvent)
        }
    }
}

//
//  RxListAdapterMoveDelegateProxy.swift
//  RxIGListKit
//
//  Created by Bruce-pac on 2019/4/2.
//

import Foundation
import IGListKit
import RxCocoa
import RxSwift

fileprivate let listAdapterMoveDelegateNotSet = ListAdapterMoveDelegateNotSet()

fileprivate final class ListAdapterMoveDelegateNotSet: NSObject, ListAdapterMoveDelegate {
    func listAdapter(_ listAdapter: ListAdapter, move object: Any, from previousObjects: [Any], to objects: [Any]) {}
}

@available(iOS 9.0, *)
final class RxListAdapterMoveDelegateProxy: DelegateProxy<ListAdapter, ListAdapterMoveDelegate>, DelegateProxyType, ListAdapterMoveDelegate {
    static func currentDelegate(for object: ListAdapter) -> ListAdapterMoveDelegate? {
        return object.moveDelegate
    }

    static func setCurrentDelegate(_ delegate: ListAdapterMoveDelegate?, to object: ListAdapter) {
        object.moveDelegate = delegate
    }

    public private(set) weak var adapter: ListAdapter?

    init(adapter: ParentObject) {
        self.adapter = adapter
        super.init(parentObject: adapter, delegateProxy: RxListAdapterMoveDelegateProxy.self)
    }

    static func registerKnownImplementations() {
        register { RxListAdapterMoveDelegateProxy(adapter: $0) }
    }

    private weak var _requiredMethodsDelegate: ListAdapterMoveDelegate? = listAdapterMoveDelegateNotSet

    private weak var _moveSubject: PublishSubject<(Any, [Any], [Any])>?

    var moveSubject: PublishSubject<(Any, [Any], [Any])> {
        if let subject = _moveSubject {
            return subject
        }
        let subject = PublishSubject<(Any, [Any], [Any])>()
        _moveSubject = subject
        return subject
    }

    func listAdapter(_ listAdapter: ListAdapter, move object: Any, from previousObjects: [Any], to objects: [Any]) {
        _moveSubject?.onNext((object, previousObjects, objects))
        _requiredMethodsDelegate?.listAdapter(listAdapter, move: object, from: previousObjects, to: objects)
    }

    override func setForwardToDelegate(_ forwardToDelegate: ListAdapterMoveDelegate?, retainDelegate: Bool) {
        _requiredMethodsDelegate = forwardToDelegate ?? listAdapterMoveDelegateNotSet
        super.setForwardToDelegate(forwardToDelegate, retainDelegate: retainDelegate)
    }

    deinit {
        _moveSubject?.onCompleted()
    }
}

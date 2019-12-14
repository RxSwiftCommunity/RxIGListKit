//
//  RxListAdapterDelegateProxy.swift
//  RxIGListKit
//
//  Created by Bruce-pac on 2019/4/2.
//

import Foundation
import IGListKit
import RxCocoa
import RxSwift

extension ListAdapter: HasDelegate {
    public typealias Delegate = ListAdapterDelegate
}

fileprivate let listAdapterDelegateNotSet = ListAdapterDelegateNotSet()

fileprivate final class ListAdapterDelegateNotSet: NSObject, ListAdapterDelegate {
    func listAdapter(_ listAdapter: ListAdapter, willDisplay object: Any, at index: Int) {}

    func listAdapter(_ listAdapter: ListAdapter, didEndDisplaying object: Any, at index: Int) {}
}

class RxListAdapterDelegateProxy
    : DelegateProxy<ListAdapter, ListAdapterDelegate>,
    DelegateProxyType,
ListAdapterDelegate {
    public private(set) weak var adapter: ListAdapter?

    init(adapter: ParentObject) {
        self.adapter = adapter
        super.init(parentObject: adapter, delegateProxy: RxListAdapterDelegateProxy.self)
    }

    static func registerKnownImplementations() {
        register { RxListAdapterDelegateProxy(adapter: $0) }
    }

    private weak var _requiredMethodsDelegate: ListAdapterDelegate? = listAdapterDelegateNotSet

    private var _willDisplaySubject: PublishSubject<(Any, Int)>?
    private var _didEndDisplayingSubject: PublishSubject<(Any, Int)>?

    internal var willDisplaySubject: PublishSubject<(Any, Int)> {
        if let subject = _willDisplaySubject {
            return subject
        }
        let subject = PublishSubject<(Any, Int)>()
        _willDisplaySubject = subject
        return subject
    }

    internal var didEndDisplayingSubject: PublishSubject<(Any, Int)> {
        if let subject = _didEndDisplayingSubject {
            return subject
        }
        let subject = PublishSubject<(Any, Int)>()
        _didEndDisplayingSubject = subject
        return subject
    }

    func listAdapter(_ listAdapter: ListAdapter, willDisplay object: Any, at index: Int) {
        _willDisplaySubject?.onNext((object, index))
        _requiredMethodsDelegate?.listAdapter(listAdapter, willDisplay: object, at: index)
    }

    func listAdapter(_ listAdapter: ListAdapter, didEndDisplaying object: Any, at index: Int) {
        _didEndDisplayingSubject?.onNext((object, index))
        _requiredMethodsDelegate?.listAdapter(listAdapter, didEndDisplaying: object, at: index)
    }

    override func setForwardToDelegate(_ forwardToDelegate: ListAdapterDelegate?, retainDelegate: Bool) {
        _requiredMethodsDelegate = forwardToDelegate ?? listAdapterDelegateNotSet
        super.setForwardToDelegate(forwardToDelegate, retainDelegate: retainDelegate)
    }

    deinit {
        _willDisplaySubject?.onCompleted()
        _didEndDisplayingSubject?.onCompleted()
    }
}

//
//  File.swift
//  RxIGListKit
//
//  Created by gxy on 2019/4/4.
//

import Foundation
import RxSwift
import IGListKit

public protocol ListAdapterMoving: AnyObject {
    var moving: Bool { get set }
    func setMoving()
}

extension ListAdapterMoving {
    public func setMoving() {
        moving = true
    }
}

public final class RxListAdapterMoveDataSource<E: SectionModelType>: RxListAdapterDataSource<E>, ListAdapterMoving {

    public var moving: Bool = false

    override public func listAdapter(_ adapter: ListAdapter, observedEvent: Event<[E]>) {
        switch observedEvent {
        case .next(let e):
            objects = e
            if moving {
                moving.toggle()
                return
            }
            adapter.performUpdates(animated: true) { _ in
            }
        default:
            print(observedEvent)
        }
    }
}

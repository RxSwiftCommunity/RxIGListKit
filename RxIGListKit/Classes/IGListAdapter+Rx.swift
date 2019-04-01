//
//  IGListAdapter+Rx.swift
//  RxIGListKit
//
//  Created by gxy on 2019/3/18.
//

import Foundation
import IGListKit
import RxSwift

extension Reactive where Base == ListAdapter {
    public func objects<DataSource: ListAdapterDataSource & RxListAdapterDataSourceType, O: ObservableType>(dataSource: DataSource) ->
        (_ source: O) -> Disposable
        where DataSource.Element == O.E {
        base.dataSource = dataSource
        return { source in
            let subscription = source.subscribe({ e in
                dataSource.listAdapter(self.base, observedEvent: e)
            })
            return Disposables.create {
                subscription.dispose()
            }
        }
    }
}

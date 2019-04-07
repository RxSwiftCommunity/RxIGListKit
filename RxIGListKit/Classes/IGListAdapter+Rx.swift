//
//  IGListAdapter+Rx.swift
//  RxIGListKit
//
//  Created by gxy on 2019/3/18.
//

import Foundation
import IGListKit
import RxCocoa
import RxSwift

public typealias RxListSingleSectionCellConfigureBlock<E: ListDiffable, Cell: UICollectionViewCell> = (E, Cell) -> Void
public typealias RxListSingleSectionCellSizeBlock<E: ListDiffable> = (E, ListCollectionContext?) -> CGSize

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

    public func objects<S: Sequence, Cell: UICollectionViewCell, O: ObservableType>(cellClass: Cell.Type, selectionDelegate: ListSingleSectionControllerDelegate? = nil)
        -> (_ source: O)
        -> (_ configureBlock: @escaping RxListSingleSectionCellConfigureBlock<S.Element, Cell>)
        -> (_ sizeBlock: @escaping RxListSingleSectionCellSizeBlock<S.Element>)
        -> (_ emptyViewProvider: EmptyViewProvider?)
        -> Disposable where O.E == S, S.Element: ListDiffable {
        return { source in
            { configureBlock1 in
                { sizeBlock in
                    { emptyViewProvider in
                        let dataSource = RxListAdapterSingleSectionDataSourceSequenceWrapper<S, Cell>(dequeueWay: .cellClass(cellClass), configureBlock: { obj, cell in
                            configureBlock1(obj, cell)
                        }, sizeBlock: sizeBlock, emptyViewProvider: emptyViewProvider)
                        dataSource.delegate = selectionDelegate
                        return self.objects(dataSource: dataSource)(source)
                    }
                }
            }
        }
    }

    public func objects<S: Sequence, Cell: UICollectionViewCell, O: ObservableType>(storyboardCellIdentifier: String, cellClass: Cell.Type, selectionDelegate: ListSingleSectionControllerDelegate? = nil)
        -> (_ source: O)
        -> (_ configureBlock: @escaping RxListSingleSectionCellConfigureBlock<S.Element, Cell>)
        -> (_ sizeBlock: @escaping RxListSingleSectionCellSizeBlock<S.Element>)
        -> (_ emptyViewProvider: EmptyViewProvider?)
        -> Disposable where O.E == S, S.Element: ListDiffable {
            return { source in
                { configureBlock1 in
                    { sizeBlock in
                        { emptyViewProvider in
                            let dataSource = RxListAdapterSingleSectionDataSourceSequenceWrapper<S, Cell>(dequeueWay: .storyboard(id: storyboardCellIdentifier), configureBlock: { obj, cell in
                                configureBlock1(obj, cell)
                            }, sizeBlock: sizeBlock, emptyViewProvider: emptyViewProvider)
                            dataSource.delegate = selectionDelegate
                            return self.objects(dataSource: dataSource)(source)
                        }
                    }
                }
            }
    }


}

public typealias WillDisplayObjectEvent = (object: ListDiffable, index: NSInteger)
public typealias DidEndDisplayingObjectEvent = (object: ListDiffable, index: NSInteger)
public typealias MoveObjectEvent = (object: ListDiffable, from: [ListDiffable], to: [ListDiffable])

extension Reactive where Base == ListAdapter {
    var delegate: DelegateProxy<ListAdapter, IGListAdapterDelegate> {
        return RxListAdapterDelegateProxy.proxy(for: base)
    }

    /**
     Reactive wrapper for `delegate` message `listAdapter:(IGListAdapter *)listAdapter willDisplayObject:(id)object atIndex:(NSInteger)index`.
     */
    public var willDisplayObject: ControlEvent<WillDisplayObjectEvent> {
        let source = RxListAdapterDelegateProxy.proxy(for: base).willDisplaySubject.map { (obj, idx) -> WillDisplayObjectEvent in
            (try castOrThrow(ListDiffable.self, obj), idx)
        }
        return ControlEvent(events: source)
    }

    /**
     Reactive wrapper for `delegate` message `- (void)listAdapter:(IGListAdapter *)listAdapter didEndDisplayingObject:(id)object atIndex:(NSInteger)index;`.
     */
    public var didEndDisplayingObject: ControlEvent<DidEndDisplayingObjectEvent> {
        let source = RxListAdapterDelegateProxy.proxy(for: base).didEndDisplayingSubject.map { (obj, idx) -> WillDisplayObjectEvent in
            (try castOrThrow(ListDiffable.self, obj), idx)
        }
        return ControlEvent(events: source)
    }

    /**
     Reactive wrapper for `moveDelegate` message ``.
     */
    @available(iOS 9.0, *)
    public func moveObject(_ delegate: ListAdapterMoving) -> ControlEvent<MoveObjectEvent> {
        let source = RxListAdapterMoveDelegateProxy.proxy(for: base).moveSubject.do(onNext: { [weak delegate] _ in
            delegate?.setMoving()
        }).map { (obj, from, to) -> MoveObjectEvent in
            (try castOrThrow(ListDiffable.self, obj),
             try castOrThrow([ListDiffable].self, from),
             try castOrThrow([ListDiffable].self, to))
        }
        return ControlEvent(events: source)
    }

    public var itemSelected: ControlEvent<IndexPath> {
        guard let view = base.collectionView else { fatalError() }
        return view.rx.itemSelected
    }

    public typealias ListWillEndDraggingEvent = (view: UICollectionView, velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)

    public var willEndDragging: ControlEvent<ListWillEndDraggingEvent> {
        guard let view = base.collectionView else { fatalError() }
        let source = view.rx.willEndDragging.map({ (v, targetContentOffset) -> ListWillEndDraggingEvent in
            (view, v, targetContentOffset)
        })
        return ControlEvent(events: source)
    }
}

func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }

    return returnValue
}

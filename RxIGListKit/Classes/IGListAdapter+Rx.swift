//
//  IGListAdapter+Rx.swift
//  RxIGListKit
//
//  Created by Bruce-pac on 2019/3/18.
//

import Foundation
import IGListKit
import RxCocoa
import RxSwift

extension Reactive where Base == ListAdapter {
    /**
     Binds sequences of elements to adapter objects using a custom reactive data used to perform the transformation.
     In case `source` observable sequence terminates successfully, the data source will present latest element
     until the subscription isn't disposed.

     - parameter dataSource: Data source used to transform elements to adapter sections.
     - parameter source: Observable sequence of items.
     - returns: Disposable object that can be used to unbind.
     */
    @available(*, deprecated, message: "It will be removed in the future.", renamed: "objects(for:)")
    public func objects<DataSource: ListAdapterDataSource & RxListAdapterDataSourceType, O: ObservableType>(dataSource: DataSource) ->
        (_ source: O) -> Disposable
        where DataSource.Element == O.Element {
            return objects(for: dataSource)
    }

    public func objects<DataSource: ListAdapterDataSource & RxListAdapterDataSourceType, O: ObservableType>(for dataSource: DataSource) ->
        (_ source: O) -> Disposable
        where DataSource.Element == O.Element {
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

    /// Binds sequences of elements to adapter objects using a custom reactive data used to perform the transformation for IGListSingleSectionController.
    ///
    /// - Parameters:
    ///   - cellClass: Type of collection view cell.
    ///   - selectionDelegate: ListSingleSectionControllerDelegate
    ///   - source: Observable sequence of objects.
    ///   - configureBlock: Transform between sequence elements and view cells.
    ///   - sizeBlock: The size for the cells.
    ///   - emptyViewProvider: The empty view for the collection view.
    /// - Returns: Disposable object that can be used to unbind.
    public func objects<S: Sequence, Cell: UICollectionViewCell, O: ObservableType>(cellClass: Cell.Type, selectionDelegate: ListSingleSectionControllerDelegate? = nil)
        -> (_ source: O)
        -> (_ configureBlock: @escaping RxListSingleSectionCellConfigureBlock<S.Element, Cell>)
        -> (_ sizeBlock: @escaping RxListSingleSectionCellSizeBlock<S.Element>)
        -> (_ emptyViewProvider: EmptyViewProvider?)
        -> Disposable where O.Element == S, S.Element: ListDiffable {
        return { source in
            { configureBlock1 in
                { sizeBlock in
                    { emptyViewProvider in
                        let dataSource = RxListAdapterSingleSectionDataSourceSequenceWrapper<S, Cell>(dequeueWay: .cellClass(cellClass), configureBlock: { obj, cell in
                            configureBlock1(obj, cell)
                        }, sizeBlock: sizeBlock, emptyViewProvider: emptyViewProvider)
                        dataSource.delegate = selectionDelegate
                        return self.objects(for: dataSource)(source)
                    }
                }
            }
        }
    }

    /// Binds sequences of elements to adapter objects using a custom reactive data used to perform the transformation for IGListSingleSectionController.
    ///
    /// - Parameters:
    ///   - storyboardCellIdentifier: StoryboardIdentifier used to dequeue cells.
    ///   - cellClass: Type of collection view cell.
    ///   - selectionDelegate: ListSingleSectionControllerDelegate
    ///   - source: Observable sequence of objects.
    ///   - configureBlock: Transform between sequence elements and view cells.
    ///   - sizeBlock: The size for the cells.
    ///   - emptyViewProvider: The empty view for the collection view.
    /// - Returns: Disposable object that can be used to unbind.
    public func objects<S: Sequence, Cell: UICollectionViewCell, O: ObservableType>(storyboardCellIdentifier: String, cellClass: Cell.Type, selectionDelegate: ListSingleSectionControllerDelegate? = nil)
        -> (_ source: O)
        -> (_ configureBlock: @escaping RxListSingleSectionCellConfigureBlock<S.Element, Cell>)
        -> (_ sizeBlock: @escaping RxListSingleSectionCellSizeBlock<S.Element>)
        -> (_ emptyViewProvider: EmptyViewProvider?)
        -> Disposable where O.Element == S, S.Element: ListDiffable {
        return { source in
            { configureBlock1 in
                { sizeBlock in
                    { emptyViewProvider in
                        let dataSource = RxListAdapterSingleSectionDataSourceSequenceWrapper<S, Cell>(dequeueWay: .storyboard(id: storyboardCellIdentifier), configureBlock: { obj, cell in
                            configureBlock1(obj, cell)
                        }, sizeBlock: sizeBlock, emptyViewProvider: emptyViewProvider)
                        dataSource.delegate = selectionDelegate
                        return self.objects(for: dataSource)(source)
                    }
                }
            }
        }
    }

    /// Binds sequences of elements to adapter objects using a custom reactive data used to perform the transformation for IGListSingleSectionController.
    ///
    /// - Parameters:
    ///   - nibName: Nib name used to dequeue cells.
    ///   - bundle: Bundle of the nib.
    ///   - cellClass: Type of collection view cell.
    ///   - selectionDelegate: ListSingleSectionControllerDelegate
    ///   - source: Observable sequence of objects.
    ///   - configureBlock: Transform between sequence elements and view cells.
    ///   - sizeBlock: The size for the cells.
    ///   - emptyViewProvider: The empty view for the collection view.
    /// - Returns: Disposable object that can be used to unbind.
    public func objects<S: Sequence, Cell: UICollectionViewCell, O: ObservableType>(nibName: String, bundle: Bundle?, cellClass: Cell.Type, selectionDelegate: ListSingleSectionControllerDelegate? = nil)
        -> (_ source: O)
        -> (_ configureBlock: @escaping RxListSingleSectionCellConfigureBlock<S.Element, Cell>)
        -> (_ sizeBlock: @escaping RxListSingleSectionCellSizeBlock<S.Element>)
        -> (_ emptyViewProvider: EmptyViewProvider?)
        -> Disposable where O.Element == S, S.Element: ListDiffable {
        return { source in
            { configureBlock1 in
                { sizeBlock in
                    { emptyViewProvider in
                        let dataSource = RxListAdapterSingleSectionDataSourceSequenceWrapper<S, Cell>(dequeueWay: .nib(name: nibName, bundle: bundle), configureBlock: { obj, cell in
                            configureBlock1(obj, cell)
                        }, sizeBlock: sizeBlock, emptyViewProvider: emptyViewProvider)
                        dataSource.delegate = selectionDelegate
                        return self.objects(for: dataSource)(source)
                    }
                }
            }
        }
    }
}

extension Reactive where Base == ListAdapter {
    var delegate: DelegateProxy<ListAdapter, ListAdapterDelegate> {
        return RxListAdapterDelegateProxy.proxy(for: base)
    }

    /**
     Reactive wrapper for `delegate` message `listAdapter:willDisplayObject:atIndex:`.
     */
    public var willDisplayObject: ControlEvent<WillDisplayObjectEvent> {
        let source = RxListAdapterDelegateProxy.proxy(for: base).willDisplaySubject.map { (obj, idx) -> WillDisplayObjectEvent in
            (try castOrThrow(ListDiffable.self, obj), idx)
        }
        return ControlEvent(events: source)
    }

    /**
     Reactive wrapper for `delegate` message `listAdapter:didEndDisplayingObject:atIndex:`.
     */
    public var didEndDisplayingObject: ControlEvent<DidEndDisplayingObjectEvent> {
        let source = RxListAdapterDelegateProxy.proxy(for: base).didEndDisplayingSubject.map { (obj, idx) -> WillDisplayObjectEvent in
            (try castOrThrow(ListDiffable.self, obj), idx)
        }
        return ControlEvent(events: source)
    }

    /**
     Reactive wrapper for `moveDelegate` message `listAdapter:moveObject:from:to:`.
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

    /**
     Reactive wrapper for `delegate` message `collectionView(_:didSelectItemAtIndexPath:)`.
     */
    public var itemSelected: ControlEvent<IndexPath> {
        guard let view = base.collectionView else { fatalError() }
        return view.rx.itemSelected
    }

    /**
     Reactive wrapper for delegate method `scrollViewWillEndDragging(_:withVelocity:targetContentOffset:)`
     */
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

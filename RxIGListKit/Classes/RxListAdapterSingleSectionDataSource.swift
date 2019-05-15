//
//  RxListAdapterSingleSectionDataSource.swift
//  RxIGListKit
//
//  Created by Bruce-pac on 2019/4/6.
//

import Foundation
import IGListKit
import RxSwift

class ListAdapterSingleSectionDataSource: NSObject, ListAdapterDataSource {
    public func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return []
    }

    public func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return ListSectionController()
    }

    public func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}

class RxListAdapterSingleSectionDataSourceSequenceWrapper<S: Sequence, Cell: UICollectionViewCell>:
    RxListAdapterSingleSectionDataSource<S.Element, Cell>, RxListAdapterDataSourceType where S.Element: ListDiffable {
    public typealias Element = S

    override init(dequeueWay: CellDequeueWay, configureBlock: @escaping RxListSingleSectionCellConfigureBlock<S.Element, Cell>, sizeBlock: @escaping RxListSingleSectionCellSizeBlock<S.Element>, emptyViewProvider: EmptyViewProvider? = nil) {
        super.init(dequeueWay: dequeueWay, configureBlock: configureBlock, sizeBlock: sizeBlock, emptyViewProvider: emptyViewProvider)
    }

    // MARK: RxListAdapterDataSourceType

    public func listAdapter(_ adapter: ListAdapter, observedEvent: Event<S>) {
        switch observedEvent {
        case .next(let e):
            objects = Array(e)
            adapter.performUpdates(animated: true) { _ in
            }
        default:
            print(observedEvent)
        }
    }
}

protocol RxListSingleSectionControllerDelegate: AnyObject {
    associatedtype E: ListDiffable
    func didSelect(_ sectionController: ListSingleSectionController, with object: E)
    func didDeselect(_ sectionController: ListSingleSectionController, with object: E)
}

class RxListAdapterSingleSectionDataSource<E: ListDiffable, Cell: UICollectionViewCell>: ListAdapterSingleSectionDataSource {
    enum CellDequeueWay {
        case cellClass(UICollectionViewCell.Type)
        case nib(name: String, bundle: Bundle?)
        case storyboard(id: String)
    }

    weak var delegate: ListSingleSectionControllerDelegate?

    let dequeueWay: CellDequeueWay
    let configureBlock: RxListSingleSectionCellConfigureBlock<E, Cell>
    let sizeBlock: RxListSingleSectionCellSizeBlock<E>
    let emptyViewProvider: EmptyViewProvider?

    init(dequeueWay: CellDequeueWay,
         configureBlock: @escaping RxListSingleSectionCellConfigureBlock<E, Cell>,
         sizeBlock: @escaping RxListSingleSectionCellSizeBlock<E>,
         emptyViewProvider: EmptyViewProvider? = nil) {
        self.dequeueWay = dequeueWay
        self.configureBlock = configureBlock
        self.sizeBlock = sizeBlock
        self.emptyViewProvider = emptyViewProvider
    }

    var objects: [E] = []

    // MARK: ListAdapterSingleSectionDataSource

    public override func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return objects
    }

    public override func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        switch dequeueWay {
        case .cellClass(let cellClass):
            let sc = ListSingleSectionController(cellClass: cellClass, configureBlock: { obj, cell in
                self.configureBlock(obj as!
                    E, cell as! Cell)
            }, sizeBlock: { (obj, context) -> CGSize in
                self.sizeBlock(obj as! E, context)
            })
            sc.selectionDelegate = delegate
            return sc
        case .nib(let name, let bundle):
            let sc = ListSingleSectionController(nibName: name, bundle: bundle, configureBlock: { obj, cell in
                self.configureBlock(obj as!
                    E, cell as! Cell)
            }, sizeBlock: { (obj, context) -> CGSize in
                self.sizeBlock(obj as! E, context)
            })
            sc.selectionDelegate = delegate
            return sc
        case .storyboard(let id):
            let sc = ListSingleSectionController(storyboardCellIdentifier: id, configureBlock: { obj, cell in
                self.configureBlock(obj as!
                    E, cell as! Cell)
            }, sizeBlock: { (obj, context) -> CGSize in
                self.sizeBlock(obj as! E, context)
            })
            sc.selectionDelegate = delegate
            return sc
        }
    }

    public override func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return emptyViewProvider?(listAdapter)
    }
}

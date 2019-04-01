//
//  MultiSectionViewController.swift
//  RxIGListKit_Example
//
//  Created by gxy on 2019/3/30.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import IGListKit
import RxIGListKit
import RxSwift
import UIKit

class MultiSectionViewController: UIViewController {
    @IBOutlet var collectionView: UICollectionView!

    lazy var adapter: ListAdapter = ListAdapter(updater: ListAdapterUpdater(), viewController: self)

    let bag = DisposeBag()
    let sectionsObservable = BehaviorSubject<[MultiSectionModel]>(value: [])

    override func viewDidLoad() {
        super.viewDidLoad()

        let baritem = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
        navigationItem.rightBarButtonItem = baritem
        baritem.rx.tap.subscribe(onNext: { [weak self] _ in
            guard var old = try? self?.sectionsObservable.value() else { fatalError() }
            let count = old.count
            if count % 2 == 0 {
                let feed = Feed(id: count, name: "\(count)")
                old.append(.feedSection(feed))
                self?.sectionsObservable.onNext(old)
            } else {
                let feed = CenterItem(name: "\(count)")
                old.append(.centerSection(feed))
                self?.sectionsObservable.onNext(old)
            }
        }).disposed(by: bag)

        adapter.collectionView = collectionView

        let ds = RxListAdapterDataSource<MultiSectionModel>(sectionControllerProvider: { (_, object) -> ListSectionController in
            switch object {
            case .feedSection:
                return FeedSectionController()
            default:
                return CenterItemSectionController()
            }
        }) { (_) -> UIView? in
            nil
        }
        sectionsObservable.bind(to: adapter.rx.objects(dataSource: ds)).disposed(by: bag)
    }
}

enum MultiSectionModel {
    case feedSection(Feed)
    case centerSection(CenterItem)
}

extension MultiSectionModel: SectionModelType {
    var object: ListDiffable {
        switch self {
        case .feedSection(let feed):
            return feed
        case .centerSection(let center):
            return center
        }
    }

    typealias ObjectType = ListDiffable
}

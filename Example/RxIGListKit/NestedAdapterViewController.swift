//
//  NestedAdapterViewController.swift
//  RxIGListKit_Example
//
//  Created by Bruce-pac on 2019/4/5.
//  Copyright © 2019 RxSwiftCommunity. All rights reserved.
//

import UIKit
import RxSwift
import RxIGListKit
import IGListKit

class NestedAdapterViewController: UIViewController {

    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    let dataSource = RxListAdapterDataSource<NestedAdapterSection>(sectionControllerProvider: { (_, obj) -> ListSectionController in
        switch obj {
        case .text(_):
            return LabelSectionController()
        case .horizontal(_):
            return HorizontalSectionController()
        }
    })

    let objectSignal = BehaviorSubject<[NestedAdapterSection]>(value: [])

    let bag = DisposeBag()

    let data: [Any] = [
        "Ridiculus Elit Tellus Purus Aenean",
        "Condimentum Sollicitudin Adipiscing",
        14,
        "Ligula Ipsum Tristique Parturient Euismod",
        "Purus Dapibus Vulputate",
        6,
        "Tellus Nibh Ipsum Inceptos",
        2
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        adapter.collectionView = collectionView
        objectSignal.bind(to: adapter.rx.objects(dataSource: dataSource)).disposed(by: bag)
        let objects = data.map { (ele) -> NestedAdapterSection in
            switch ele {
            case is String:
                return .text(ele as! String)
            case is Int:
                return .horizontal(ele as! Int)
            default:
                fatalError()
            }
        }
        objectSignal.onNext(objects)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }

}

enum NestedAdapterSection {
    case text(String)
    case horizontal(Int)
}

extension NestedAdapterSection: SectionModelType {
    typealias ObjectType = ListDiffable
    var object: ListDiffable {
        switch self {
        case .text(let t):
            return t as NSString
        case .horizontal(let i):
            return i as NSNumber
        }
    }
}

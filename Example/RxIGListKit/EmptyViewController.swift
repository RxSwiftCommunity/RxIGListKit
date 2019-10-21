//
//  EmptyViewController.swift
//  RxIGListKit_Example
//
//  Created by Bruce-pac on 2019/4/5.
//  Copyright © 2019 RxSwiftCommunity. All rights reserved.
//

import IGListKit
import RxCocoa
import RxIGListKit
import RxSwift
import UIKit

class EmptyViewController: UIViewController {
    lazy var adapter: ListAdapter = {
        ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()
    let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = UIColor(white: 0.9, alpha: 1)
        return collectionView
    }()

    let bag = DisposeBag()

    let objectSignal = BehaviorSubject<[Int]>(value: [])

    let removeSignal = BehaviorSubject<[Int]>(value: [])

    let emptyLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "No more data!"
        label.backgroundColor = .clear
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        let addItem = UIBarButtonItem(barButtonSystemItem: .add,
                                      target: nil,
                                      action: nil)

        navigationItem.rightBarButtonItem = addItem
        view.addSubview(collectionView)
        adapter.collectionView = collectionView

        let dataSource = RxListAdapterDataSource<Int>(sectionControllerProvider: { (_, _) -> ListSectionController in
            RemoveSectionController(delegate: self)
        }, emptyViewProvider: { [weak self] (_) -> UIView? in
            return self?.emptyLabel
        })

        objectSignal.bind(to: adapter.rx.objects(for: dataSource)).disposed(by: bag)

        let addSignal = addItem.rx.tap.withLatestFrom(objectSignal).map { (old) -> [Int] in
            let count = old.count
            var new = old
            new.append(count + 1)
            return new
        }
        Observable.merge(addSignal,removeSignal).bind(to: objectSignal).disposed(by: bag)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
}

extension EmptyViewController: RemoveSectionControllerDelegate {
    func removeSectionControllerWantsRemoved(_ sectionController: RemoveSectionController) {
        guard var data = try? objectSignal.value() else { return }

        let section = adapter.section(for: sectionController)
        guard let object = adapter.object(atSection: section) as? Int, let index = data.firstIndex(of: object) else { return }
        data.remove(at: index)
        removeSignal.onNext(data)
    }
}

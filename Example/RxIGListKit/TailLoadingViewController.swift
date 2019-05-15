//
//  TailLoadingViewController.swift
//  RxIGListKit_Example
//
//  Created by Bruce-pac on 2019/4/4.
//  Copyright © 2019 RxSwiftCommunity. All rights reserved.
//

import IGListKit
import RxIGListKit
import RxSwift
import UIKit

class TailLoadingViewController: UIViewController {
    lazy var adapter: ListAdapter = {
        ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()

    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    let loading = BehaviorSubject<Bool>(value: false)

    lazy var items = Array(0...20).map { NSString(string: "\($0)") }

    let itemSignal = BehaviorSubject<[NSString]>(value: [])

    let spinToken: NSString = "spinner"

    let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .white
        view.addSubview(collectionView)
        adapter.collectionView = collectionView
        itemSignal.onNext(items)
        rxBind()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }

    func rxBind() {
        let ds = RxListAdapterDataSource<NSString>(sectionControllerProvider: { [unowned self] (_, object) -> ListSectionController in
            if object == self.spinToken {
                return spinnerSectionController()
            } else {
                return LabelSectionController()
            }
        })
        itemSignal.debug().bind(to: adapter.rx.objects(dataSource: ds)).disposed(by: bag)

        let footDrag = adapter.rx.willEndDragging.map { (view, _, offset) -> Bool in
            let distance = view.contentSize.height - (offset.pointee.y + view.bounds.height)
            return distance < 200
        }
        let footRefresh = footDrag.withLatestFrom(loading) { (drag, loading) -> Bool in
            drag && !loading
            }.filter { $0 }.share()

        let addLoadSection = footRefresh.withLatestFrom(itemSignal).flatMapLatest { (old) -> Observable<[NSString]> in
            var copy = old
            copy.append(NSString(string: "spinner"))
            return Observable.just(copy)
            }.share()
        addLoadSection.subscribe(onNext: { [weak self] spinToken in
            guard let self = self else { return }
            self.itemSignal.onNext(spinToken)
        }).disposed(by: bag)

        let requestAction = addLoadSection.withLatestFrom(itemSignal).flatMapLatest { (old) -> Observable<[NSString]> in
            Observable.create({ (observer) -> Disposable in
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                    let count = old.count - 1
                    let delta = Array(count..<count + 5).map { NSString(string: "\($0)") }
                    observer.onNext(delta)
                    observer.onCompleted()
                })
                return Disposables.create()
            })
            }.share()
        requestAction.subscribe(onNext: { [weak self] delta in
            guard var new = try? self?.itemSignal.value() else { return }
            new.removeLast()
            new.append(contentsOf: delta)
            self?.itemSignal.onNext(new)
        }).disposed(by: bag)

        Observable.merge([footRefresh, requestAction.map { _ in false }]).bind(to: loading).disposed(by: bag)
    }
}

extension Observable {
    func mapToVoid() -> Observable<Void> {
        return map { _ in }
    }
}

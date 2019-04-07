//
//  ViewController.swift
//  RxIGListKit
//
//  Created by Bruce-pac on 02/27/2019.
//  Copyright (c) 2019 Bruce-pac. All rights reserved.
//

import UIKit
import RxIGListKit
import IGListKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    let collectionView: UICollectionView = {
        let flow = UICollectionViewFlowLayout()
        let varia = UICollectionView(frame: CGRect.zero, collectionViewLayout: flow)
        varia.backgroundColor = UIColor.groupTableViewBackground
        return varia
    }()

    lazy var adapter: ListAdapter = ListAdapter(updater: ListAdapterUpdater(), viewController: self)

    let bag = DisposeBag()

    let objectObservable: BehaviorRelay = BehaviorRelay<[Feed]>(value: [])

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addObject))

        if #available(iOS 9.0, *) {
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.handleLongGesture(gesture:)))
            collectionView.addGestureRecognizer(longPressGesture)
        }

        view.addSubview(collectionView)
        adapter.collectionView = collectionView
        adapter.collectionViewDelegate = self
        adapter.add(self)
        rxBind()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }

    func rxBind() {
        let ds = RxListAdapterDataSource<Feed>(sectionControllerProvider: { (adapter, object) -> ListSectionController in
            return FeedSectionController()
        }) { (_) -> UIView? in
            return nil
        }
        objectObservable.bind(to: adapter.rx.objects(dataSource: ds)).disposed(by: bag)

        adapter.rx.willDisplayObject.subscribe(onNext: { (obj, idx) in
            print("willDisplayObject \(obj) at \(idx)")
        }).disposed(by: bag)
        adapter.rx.didEndDisplayingObject.subscribe(onNext: { (obj, idx) in
            print("didEndDisplayingObject \(obj) at \(idx)")
        }).disposed(by: bag)

//        adapter.rx.moveObject(ds).subscribe(onNext: { [weak self] (_, _, to) in
//
//            self?.objectObservable.accept(to as! [Feed])
//            }).disposed(by: bag)
//        adapter.rx.itemSelected.subscribe(onNext: { (idx) in
//            print("\(idx)")
//        }).disposed(by: bag)
    }

    @objc func addObject() {
        let count = objectObservable.value.count
        let feed = Feed(id: count + 1, name: "\(count + 1)")
        var new = objectObservable.value
        new.append(feed)
        objectObservable.accept(new)
    }

    @available(iOS 9.0, *)
    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            let touchLocation = gesture.location(in: self.collectionView)
            guard let selectedIndexPath = collectionView.indexPathForItem(at: touchLocation) else {
                break
            }
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            if let view = gesture.view {
                let position = gesture.location(in: view)
                collectionView.updateInteractiveMovementTargetPosition(position)
            }
        case .ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }

}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("\(#function), \(indexPath)")
    }
}

extension ViewController: ListAdapterUpdateListener {
    func listAdapter(_ listAdapter: ListAdapter, didFinish update: IGListAdapterUpdateType, animated: Bool) {
        print("\(update.rawValue), \(animated)")
    }
}

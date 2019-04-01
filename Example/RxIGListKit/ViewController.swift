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
    var objects = [Feed(id: 1, name: "1"), Feed(id: 2, name: "2")]
    let objectObservable: BehaviorRelay = BehaviorRelay<[Feed]>(value: [])


    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addObject))

        view.addSubview(collectionView)
        adapter.collectionView = collectionView
        let ds = RxListAdapterDataSource<Feed>(sectionControllerProvider: { (adapter, object) -> ListSectionController in
            return FeedSectionController()
        }) { (_) -> UIView? in
            return nil
        }
        objectObservable.bind(to: adapter.rx.objects(dataSource: ds)).disposed(by: bag)

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }

    @objc func addObject() {
        let count = objectObservable.value.count
        let feed = Feed(id: count + 1, name: "\(count + 1)")
        var new = objectObservable.value
        new.append(feed)
        objectObservable.accept(new)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

//
//  MixedDataViewController.swift
//  RxIGListKit_Example
//
//  Created by Bruce-pac on 2019/4/4.
//  Copyright © 2019 RxSwiftCommunity. All rights reserved.
//

import IGListKit
import RxIGListKit
import RxSwift
import UIKit

class MixedDataViewController: UIViewController {
    lazy var adapter: ListAdapter = {
        ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()

    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    var data: [Any] = [
        "Maecenas faucibus mollis interdum. Duis mollis, est non commodo luctus, nisi erat porttitor ligula, eget lacinia odio sem nec elit.",
        GridItem(color: UIColor(red: 237 / 255.0, green: 73 / 255.0, blue: 86 / 255.0, alpha: 1), itemCount: 6),
        User(pk: 2, name: "Ryan Olson", handle: "ryanolsonk"),
        "Praesent commodo cursus magna, vel scelerisque nisl consectetur et.",
        User(pk: 4, name: "Oliver Rickard", handle: "ocrickard"),
        GridItem(color: UIColor(red: 56 / 255.0, green: 151 / 255.0, blue: 240 / 255.0, alpha: 1), itemCount: 5),
        "Nullam quis risus eget urna mollis ornare vel eu leo. Praesent commodo cursus magna, vel scelerisque nisl consectetur et.",
        User(pk: 3, name: "Jesse Squires", handle: "jesse_squires"),
        GridItem(color: UIColor(red: 112 / 255.0, green: 192 / 255.0, blue: 80 / 255.0, alpha: 1), itemCount: 3),
        "Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh, ut fermentum massa justo sit amet risus.",
        GridItem(color: UIColor(red: 163 / 255.0, green: 42 / 255.0, blue: 186 / 255.0, alpha: 1), itemCount: 7),
        User(pk: 1, name: "Ryan Nystrom", handle: "_ryannystrom")
    ]

    let segments: [(String, Any.Type?)] = [
        ("All", nil),
        ("Colors", GridItem.self),
        ("Text", String.self),
        ("Users", User.self)
    ]

    let bag = DisposeBag()

    let itemSignal = BehaviorSubject<[MixedDataSection]>(value: [])

    override func viewDidLoad() {
        super.viewDidLoad()

        let objects = data.mapToMixedDataSection()
        itemSignal.onNext(objects)

        let control = UISegmentedControl(items: segments.map { $0.0 })
        control.selectedSegmentIndex = 0
        navigationItem.titleView = control
        if #available(iOS 9.0, *) {
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(MixedDataViewController.handleLongGesture(gesture:)))
            collectionView.addGestureRecognizer(longPressGesture)
        }

        view.addSubview(collectionView)
        adapter.collectionView = collectionView
        rxBind()

        control.rx.selectedSegmentIndex.map { [unowned self] (idx) -> [MixedDataSection] in
            guard let selectedClass = self.segments[idx].1 else { return objects }
            return self.data.filter { type(of: $0) == selectedClass }.mapToMixedDataSection()
        }.bind(to: itemSignal).disposed(by: bag)
    }

    @available(iOS 9.0, *)
    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            let touchLocation = gesture.location(in: collectionView)
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }

    func rxBind() {
        let ds = RxListAdapterMoveDataSource<MixedDataSection>(sectionControllerProvider: { (_, section) -> ListSectionController in
            switch section {
            case .text:
                return ExpandableSectionController()
            case .grid:
                return GridSectionController(isReorderable: true)
            case .user:
                return UserSectionController(isReorderable: true)
            }
        })
        itemSignal.bind(to: adapter.rx.objects(dataSource: ds)).disposed(by: bag)
        adapter.rx.moveObject(ds).map({ (_,_,to) -> [MixedDataSection] in
           return to.map({ (obj) -> MixedDataSection in
                switch obj {
                case is String:
                    return .text(obj as! String)
                case is GridItem:
                    return .grid(obj as! GridItem)
                default:
                    return .user(obj as! User)
                }
            })
        }).subscribe(onNext: { [weak self] (new) in
            self?.itemSignal.onNext(new)
        }).disposed(by: bag)
    }
}

enum MixedDataSection {
    case text(String)
    case grid(GridItem)
    case user(User)
}

extension MixedDataSection: SectionModelType {
    typealias ObjectType = ListDiffable
    var object: ListDiffable {
        switch self {
        case .text(let text):
            return text as NSString
        case .grid(let grid):
            return grid
        case .user(let user):
            return user
        }
    }
}


fileprivate extension Array {
    func mapToMixedDataSection() -> [MixedDataSection] {
        return map({ (obj) -> MixedDataSection in
            switch obj {
            case is String:
                return .text(obj as! String)
            case is GridItem:
                return .grid(obj as! GridItem)
            default:
                return .user(obj as! User)
            }
        })
    }
}

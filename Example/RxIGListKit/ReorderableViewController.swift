/**
 Copyright (c) Facebook, Inc. and its affiliates.
 
 The examples provided by Facebook are for non-commercial testing and evaluation
 purposes only. Facebook reserves all rights not expressly granted.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 FACEBOOK BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import IGListKit
import UIKit
import RxSwift
import RxIGListKit

final class ReorderableViewController: UIViewController {

    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()

    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    var data = Array(0..<20).map {
        "Cell: \($0 + 1)"
    }

    let bag = DisposeBag()


    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 9.0, *) {
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(ReorderableViewController.handleLongGesture(gesture:)))
            collectionView.addGestureRecognizer(longPressGesture)
        }

        view.addSubview(collectionView)
        adapter.collectionView = collectionView
        let dataSource = RxListAdapterMoveDataSource<String>(sectionControllerProvider: { (_, _) -> ListSectionController in
            return ReorderableSectionController()
        })
        let objectSignal = Observable.just(data)

        let moveSignal = adapter.rx.moveObject(dataSource).map { (_, _, to) -> [String] in
            return to as! [String]
        }
        Observable.merge(objectSignal, moveSignal).bind(to: adapter.rx.objects(for: dataSource)).disposed(by: bag)

//        if #available(iOS 9.0, *) {
//            adapter.moveDelegate = self
//        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }

    // MARK: - Interactive Reordering

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

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

final class StackedViewController: UIViewController {

    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 1)
    }()

    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    let data = [128, 256, 64]

    let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        view.addSubview(collectionView)
        adapter.collectionView = collectionView

        let ds = RxListAdapterDataSource<Int>(sectionControllerProvider: { (_, _) -> ListSectionController in
            // note that each child section controller is designed to handle an Int (or no data)
            let sectionController = ListStackedSectionController(sectionControllers: [
                WorkingRangeSectionController(),
                DisplaySectionController(),
                HorizontalSectionController()
                ])
            sectionController.inset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
            return sectionController
        })
        let objectSignal = Observable.just(data)
        objectSignal.bind(to: adapter.rx.objects(for: ds)).disposed(by: bag)

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
}

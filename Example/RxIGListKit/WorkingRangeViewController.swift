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
import RxIGListKit
import RxSwift

final class WorkingRangeViewController: UIViewController {

    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 2)
    }()

    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    let data: [Int] = {
        var set = Set<Int>() // only use unique values
        while set.count < 20 {
            set.insert( Int(arc4random_uniform(200)) + 200 )
        }
        return Array(set)
    }()

    let bag = DisposeBag()


    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(collectionView)
        adapter.collectionView = collectionView
        let objectSignal = Observable.just(data)
        let ds = RxListAdapterDataSource<Int>(sectionControllerProvider: { (_, _) -> ListSectionController in
            return WorkingRangeSectionController()
        })

        objectSignal.bind(to: adapter.rx.objects(for: ds)).disposed(by: bag)

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }

}

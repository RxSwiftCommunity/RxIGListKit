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

final class SingleSectionStoryboardViewController: UIViewController, ListSingleSectionControllerDelegate {

    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()

    @IBOutlet weak var collectionView: UICollectionView!

    let data = Array(0..<20) as [NSNumber]
    let bag = DisposeBag()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        adapter.collectionView = collectionView
        let objectSignal = Observable.just(data)
        let config = adapter.rx.objects(storyboardCellIdentifier: "cell", cellClass: StoryboardCell.self, selectionDelegate: self)(objectSignal)
        let size = config({ (obj, cell) in
            cell.text = "Cell: \(obj.intValue + 1)"
        })
        let emptyView = size({ (obj, context) in
            guard let context = context else { return .zero }
            return CGSize(width: context.containerSize.width, height: 44)
        })
        emptyView(nil).disposed(by: bag)
    }

    // MARK: - ListSingleSectionControllerDelegate

    func didSelect(_ sectionController: ListSingleSectionController, with object: Any) {
        let section = adapter.section(for: sectionController) + 1
        let alert = UIAlertController(title: "Section \(section) was selected \u{1F389}", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

}

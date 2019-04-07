//
//  SearchViewController.swift
//  RxIGListKit_Example
//
//  Created by gxy on 2019/4/4.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import IGListKit
import RxIGListKit
import RxSwift
import RxCocoa
import UIKit

class SearchViewController: UIViewController {
    lazy var adapter: ListAdapter = {
        ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()

    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    let searchBar: UISearchBar = {
        let varia = UISearchBar(frame: .zero)
        return varia
    }()

    lazy var words: [NSString] = {
        // swiftlint:disable:next
        let str = "Humblebrag skateboard tacos viral small batch blue bottle, schlitz fingerstache etsy squid. Listicle tote bag helvetica XOXO literally, meggings cardigan kickstarter roof party deep v selvage scenester venmo truffaut. You probably haven't heard of them fanny pack austin next level 3 wolf moon. Everyday carry offal brunch 8-bit, keytar banjo pinterest leggings hashtag wolf raw denim butcher. Single-origin coffee try-hard echo park neutra, cornhole banh mi meh austin readymade tacos taxidermy pug tattooed. Cold-pressed +1 ethical, four loko cardigan meh forage YOLO health goth sriracha kale chips. Mumblecore cardigan humblebrag, lo-fi typewriter truffaut leggings health goth."
        var unique = Set<String>()
        var words = [String]()
        let range = str.startIndex ..< str.endIndex
        str.enumerateSubstrings(in: range, options: .byWords) { substring, _, _, _ in
            guard let substring = substring else { return }
            if !unique.contains(substring) {
                unique.insert(substring)
                words.append(substring)
            }
        }
        return words as [NSString]
    }()

    let bag = DisposeBag()

    let itemSignal = BehaviorSubject<[NSString]>(value: [])

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        collectionView.backgroundColor = .white
        view.addSubview(collectionView)
        adapter.collectionView = collectionView
        view.addSubview(searchBar)
        rxBind()
        itemSignal.onNext(words)

        searchBar.rx.text.map({ [unowned self] (filterString) -> [NSString] in
            guard let f =  filterString, f.isEmpty == false else { return self.words }
            let res = self.words.filter({ (word) -> Bool in
                word.lowercased.contains(f.lowercased())
            })
            return res
        }).bind(to: itemSignal).disposed(by: bag)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let y = (navigationController?.navigationBar.bounds.height)! + UIApplication.shared.statusBarFrame.height
        var bottom: CGFloat = 0
        if #available(iOS 11.0, *) {
            bottom = view.safeAreaInsets.bottom
        } else {
            // Fallback on earlier versions
        }

        searchBar.frame = CGRect(x: 0, y: y, width: view.frame.width, height: 50)
        collectionView.frame = CGRect(x: 0, y: searchBar.frame.maxY, width: view.frame.width, height: view.frame.height - searchBar.frame.maxY - bottom)
    }

    func rxBind() {
        let ds = RxListAdapterDataSource<NSString>(sectionControllerProvider: { (_, _) -> ListSectionController in
            LabelSectionController()
        })
        itemSignal.bind(to: adapter.rx.objects(dataSource: ds)).disposed(by: bag)
    }

}

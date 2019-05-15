//
//  RxListBindingSectionControllerDataSource.swift
//  RxIGListKit
//
//  Created by Bruce-pac on 2019/4/7.
//

import Foundation
import IGListKit

public protocol BindableViewModelType {
    associatedtype ViewModelType: ListDiffable
    var viewModel: ViewModelType { get }
}

open class ListBindingSectionControllerSwiftWrapper<Object: ListDiffable, ViewModel: BindableViewModelType>: ListBindingSectionController<ListDiffable>, ListBindingSectionControllerDataSource {
    public override init() {
        super.init()
        dataSource = self
        configWhenInit()
    }

    var bindableViewModels: [ViewModel] = []

    open func configWhenInit() {}

    open func viewModelsFor(_ object: Object) -> [ViewModel] {
        fatalError("Abstract method, please override")
    }

    open func cellFor(_ viewModel: ViewModel, at index: Int) -> UICollectionViewCell & ListBindable {
        fatalError("Abstract method, please override")
    }

    open func sizeFor(_ viewModel: ViewModel, at index: Int) -> CGSize {
        fatalError("Abstract method, please override")
    }

    public final func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, viewModelsFor object: Any) -> [ListDiffable] {
        guard let obj = object as? Object else { return [] }
        bindableViewModels = viewModelsFor(obj)
        return bindableViewModels.map { $0.viewModel }
    }

    public final func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, cellForViewModel viewModel: Any, at index: Int) -> UICollectionViewCell & ListBindable {
        guard let viewModel = viewModel as? ListDiffable else { fatalError() }
        let vm = lookupBindableViewModel(with: viewModel)
        return cellFor(vm, at: index)
    }

    public final func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, sizeForViewModel viewModel: Any, at index: Int) -> CGSize {
        guard let viewModel = viewModel as? ListDiffable else { fatalError() }
        let vm = lookupBindableViewModel(with: viewModel)
        return sizeFor(vm, at: index)
    }

    func lookupBindableViewModel(with viewModel: ListDiffable) -> ViewModel {
        let firstIndex = bindableViewModels.firstIndex { (vm) -> Bool in
            vm.viewModel.diffIdentifier().isEqual(viewModel.diffIdentifier())
        }
        guard let idx = firstIndex else { fatalError("not find \(viewModel)") }
        let vm = bindableViewModels[idx]
        return vm
    }
}

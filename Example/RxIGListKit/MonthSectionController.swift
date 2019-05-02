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

enum MonthSectionViewModelType {
    case title(MonthTitleViewModel)
    case day(DayViewModel)
    case appointment(NSString)
}

extension MonthSectionViewModelType: BindableViewModelType {
    typealias ViewModelType = ListDiffable
    var viewModel: ListDiffable {
        switch self {
        case .title(let model):
            return model
        case .day(let m):
            return m
        case .appointment(let s):
            return s
        }
    }
}

final class MonthSectionController: ListBindingSectionControllerSwiftWrapper<Month,MonthSectionViewModelType>, ListBindingSectionControllerSelectionDelegate {

    private var selectedDay: Int = -1

    override func configWhenInit() {
        selectionDelegate = self
    }

    override func viewModelsFor(_ object: Month) -> [MonthSectionViewModelType] {
        let month = object

        let date = Date()
        let today = Calendar.current.component(.day, from: date)

        var viewModels = [MonthSectionViewModelType]()

        let title = MonthSectionViewModelType.title(MonthTitleViewModel(name: month.name))
        viewModels.append(title)

        for day in 1..<(month.days + 1) {
            let viewModel = DayViewModel(
                day: day,
                today: day == today,
                selected: day == selectedDay,
                appointments: month.appointments[day]?.count ?? 0
            )
            let dayvm = MonthSectionViewModelType.day(viewModel)
            viewModels.append(dayvm)
        }

        for appointment in month.appointments[selectedDay] ?? [] {
            viewModels.append(MonthSectionViewModelType.appointment(appointment))
        }

        return viewModels
    }

    override func cellFor(_ viewModel: MonthSectionViewModelType, at index: Int) -> UICollectionViewCell & ListBindable {
        let cellClass: AnyClass
        switch viewModel {
        case .title(_):
            cellClass = MonthTitleCell.self
        case .day(_):
            cellClass = CalendarDayCell.self
        case .appointment(_):
            cellClass = LabelCell.self
        }
        guard let cell = collectionContext?.dequeueReusableCell(of: cellClass, for: self, at: index) as? UICollectionViewCell & ListBindable
        else { fatalError() }
        return cell
    }

    override func sizeFor(_ viewModel: MonthSectionViewModelType, at index: Int) -> CGSize {
        guard let width = collectionContext?.containerSize.width else { return .zero }
        switch viewModel {
        case .title(_):
            return CGSize(width: width, height: 30.0)
        case .day(_):
            let square = width / 7.0
            return CGSize(width: square, height: square)
        case .appointment(_):
            return CGSize(width: width, height: 55.0)
        }
    }

    // MARK: ListBindingSectionControllerSelectionDelegate

    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, didSelectItemAt index: Int, viewModel: Any) {
        guard let dayViewModel = viewModel as? DayViewModel else { return }
        if dayViewModel.day == selectedDay {
            selectedDay = -1
        } else {
            selectedDay = dayViewModel.day
        }
        update(animated: true)
    }

    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, didDeselectItemAt index: Int, viewModel: Any) {}

    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, didHighlightItemAt index: Int, viewModel: Any) {}

    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, didUnhighlightItemAt index: Int, viewModel: Any) {}

}

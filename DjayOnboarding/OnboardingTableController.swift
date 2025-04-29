//
//  OnboardingTableController.swift
//  DjayOnboarding
//
//  Created by Pal Granum on 26/04/2025.
//

import UIKit
import Combine
 
/// A reusable table view controller for onboarding screens. It will center content vertically if content height is less than the screen height.
public class OnboardingTableController: UITableViewController {
    private(set) var dataSource: UITableViewDiffableDataSource<Int, OnboardingTableItem>!
    private var token: AnyCancellable?

    init(_ snapshots: AnyPublisher<OnboardingTableSnapshot, Never>) {
        super.init(nibName: nil, bundle: nil)
        tableView.backgroundColor = .clear
        tableView.sectionHeaderTopPadding = 0
        tableView.allowsSelection = false
        tableView.indicatorStyle = .white
        tableView.verticalScrollIndicatorInsets.right = 5
        self.dataSource = UITableViewDiffableDataSource<Int, OnboardingTableItem>(tableView: tableView) { tableView, indexPath, item in
            switch item {
            case .djayLogo: ImageCell(UIImage(named: "djayLogo")!)
            case .info: DJayInfoCell()
            case .skillSelection(let viewModel): SkillSelectionCell(viewModel)
            }
        }
        var isAnimated = false
        token = snapshots.sink { [weak self] in
            self?.dataSource?.apply($0, animatingDifferences: isAnimated)
            self?.updateContentInset(isAnimated)
            isAnimated = true
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateContentInset(false)
    }

    private func updateContentInset(_ isAnimated: Bool) {
        let requiredHeight = dataSource.snapshot().itemIdentifiers.map(\.height).reduce(0, +)
        let redundantHeight = view.bounds.height - requiredHeight
        let topPadding: CGFloat = max(0, redundantHeight * 0.5 - view.safeAreaInsets.top)
        let action: () -> Void = {
            self.tableView.contentInset.top = topPadding
        }
        if isAnimated {
            UIView.animate(withDuration: 0.3, animations: action)
        } else {
            UIView.performWithoutAnimation(action)
        }
    }

    public override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        dataSource.snapshot().itemIdentifiers[indexPath.row].height
    }
}

//
//  WelcomeTableController.swift
//  DjayOnboarding
//
//  Created by Pal Granum on 17/04/2025.
//

import UIKit
import Combine

final public class WelcomeTableController: UIViewController {
    private let tableController: OnboardingTableController
    private let welcomeLabel = UILabel()
    private var token: AnyCancellable?

    init(_ snapshots: AnyPublisher<OnboardingTableSnapshot, Never>) {
        self.tableController = OnboardingTableController(snapshots)
        super.init(nibName: nil, bundle: nil)
        addChild(tableController)
        view.addSubview(tableController.view)
        tableController.didMove(toParent: self)
        welcomeLabel.font = .systemFont(ofSize: 22, weight: .regular)
        welcomeLabel.textColor = .white
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.minimumLineHeight = 22
        paragraphStyle.maximumLineHeight = 22
        let attributedText = NSAttributedString(
            string: "Welcome to djay!",
            attributes: [
                .kern: 0.02 * 22, // 2% letter spacing = 0.44 points
                .paragraphStyle: paragraphStyle
            ]
        )
        welcomeLabel.attributedText = attributedText
        welcomeLabel.textAlignment = .center
        view.addSubview(welcomeLabel)
        var isAnimated = false
        token = snapshots.sink { [weak self] in
            self?.updateWelcomeLabel($0.itemIdentifiers.count > 1, isAnimated: isAnimated)
            isAnimated = true
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableController.view.frame = view.bounds
        updateWelcomeLabel(tableController.dataSource.snapshot().itemIdentifiers.count > 1, isAnimated: false)
    }

    private func updateWelcomeLabel(_ isHidden: Bool, isAnimated: Bool) {
        let height = welcomeLabel.intrinsicContentSize.height
        let padding: CGFloat = 24
        let frame = CGRect(x: 0, y: isHidden ? view.bounds.height : view.bounds.height - height - padding, width: view.bounds.width, height: height)
        let alpha: CGFloat = isHidden ? 0 : 1
        let action: () -> Void = {
            self.welcomeLabel.frame = frame
            self.welcomeLabel.alpha = alpha
        }
        if isAnimated {
            UIView.animate(withDuration: 0.3, animations: action)
        } else {
            UIView.performWithoutAnimation(action)
        }
    }
}

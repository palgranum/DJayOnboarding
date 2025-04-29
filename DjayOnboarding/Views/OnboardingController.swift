//
//  OnboardingController.swift
//  DjayOnboarding
//
//  Created by Pal Granum on 16/04/2025.
//

import UIKit
import Combine

public protocol OnboardingViewModelType {
    func didTapButton()
    var pageIndex: AnyPublisher<Int, Never> { get }
    var buttonTitle: AnyPublisher<String, Never> { get }
    var isButtonEnabled: AnyPublisher<Bool, Never> { get }
    var screenUpdates: AnyPublisher<OnboardingScreen, Never> { get }
}

public enum OnboardingScreen {
    case welcome(AnyPublisher<OnboardingTableSnapshot, Never>)
    case skillSelection(SkillSelectionViewModelType)
    case congratulations(CongratulationsViewModelType)
    case error(Error)
}

/// The main controller for the onboarding process. It contains a shared button and pageIndicator and a page view controller that will push the next screen/vc
final public class OnboardingController: UIViewController {
    private let button = UIButton()
    private let gradientLayer = CAGradientLayer()
    private let pageIndicator = UIPageControl()
    private let pageController = UIPageViewController(transitionStyle: .scroll,
                                                      navigationOrientation: .horizontal)
    private var pageControllerBottomConstraint: NSLayoutConstraint?
    private let viewModel: OnboardingViewModelType
    private var bag = Set<AnyCancellable>()

    init(_ viewModel: OnboardingViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        view.directionalLayoutMargins.leading = Self.horizontalInset
        view.directionalLayoutMargins.trailing = Self.horizontalInset
        gradientLayer.colors = [UIColor.gradientStart.cgColor, UIColor.gradientEnd.cgColor]
        view.layer.addSublayer(gradientLayer)
        var buttonConfig = UIButton.Configuration.filled()
        buttonConfig.baseBackgroundColor = .buttonBlue
        buttonConfig.baseForegroundColor = .white
        buttonConfig.cornerStyle = .medium
        button.configuration = buttonConfig
        pageIndicator.isUserInteractionEnabled = false
        pageIndicator.numberOfPages = 4
        viewModel.pageIndex.assign(to: \.currentPage, on: pageIndicator).store(in: &bag)
        addChild(pageController)
        view.addSubviewWithAutoLayout(pageController.view)
        pageController.didMove(toParent: self)
        view.addSubviewWithAutoLayout(button)
        view.addSubviewWithAutoLayout(pageIndicator)
        NSLayoutConstraint.activate(buttonConstraints + pageIndicatorConstraints + pageControllerConstraints)
        viewModel.isButtonEnabled.sink(receiveValue: { [button] in
            button.alpha = $0 ? 1 : 0.3
            button.isUserInteractionEnabled = $0
        }).store(in: &bag)
        viewModel.buttonTitle.sink(receiveValue: { [button] in
            button.setTitle($0, for: .normal)
        }).store(in: &bag)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        viewModel.screenUpdates.sink(receiveValue: { [weak self] in
            self?.setContentScreen($0)
        }).store(in: &bag)
    }

    required init?(coder: NSCoder) { fatalError() }

    public override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.layer.bounds
    }

    @objc private func didTapButton() {
        viewModel.didTapButton()
    }

    private func setContentScreen(_ screen: OnboardingScreen) {
        pageControllerBottomConstraint?.isActive = false
        let newController: UIViewController
        switch screen {
        case .welcome(let snapshots):
            newController = WelcomeTableController(snapshots)
        case .skillSelection(let viewModel):
            var snap = OnboardingTableSnapshot()
            snap.appendSections([0])
            snap.appendItems([.skillSelection(viewModel)], toSection: 0)
            newController = OnboardingTableController(Just(snap).eraseToAnyPublisher())
        case .congratulations(let viewModel):
            newController = CongratulationsViewController(viewModel)
        case .error(let error):
            newController = ErrorViewController(error.localizedDescription)
        }
        let newConstraint: NSLayoutConstraint
        switch screen {
        case .congratulations:
            newConstraint = pageController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        default:
            newConstraint = pageController.view.bottomAnchor.constraint(equalTo: button.topAnchor)
        }
        newConstraint.isActive = true
        pageControllerBottomConstraint = newConstraint
        pageController.setViewControllers([newController], direction: .forward, animated: true)
    }
}

extension OnboardingController {
    private static var horizontalInset: CGFloat { 32 }

    static var buttonWidth: CGFloat {
        // We use a fixed width based on portrait layout, otherwise the button will look weird/too wide in landscape
        (UIScreen.main.nativeBounds.width / UIScreen.main.nativeScale) - 2 * horizontalInset
    }
}

private extension OnboardingController {
    var buttonConstraints: [NSLayoutConstraint] {
        [button.widthAnchor.constraint(equalToConstant: Self.buttonWidth),
         button.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
         button.bottomAnchor.constraint(equalTo: pageIndicator.topAnchor, constant: -8),
         button.heightAnchor.constraint(equalToConstant: 44)]
    }

    var pageIndicatorConstraints: [NSLayoutConstraint] {
        [pageIndicator.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
         pageIndicator.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -8)]
    }

    var pageControllerConstraints: [NSLayoutConstraint] {
        [pageController.view.topAnchor.constraint(equalTo: view.topAnchor),
         pageController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
         pageController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)]
    }
}


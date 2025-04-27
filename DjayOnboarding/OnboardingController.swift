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
    var welcomeSnapshots: AnyPublisher<OnboardingTableSnapshot, Never> { get }
    var screenUpdates: AnyPublisher<OnboardingTableSnapshot, Never> { get }
}

final public class OnboardingController: UIViewController {
    private let button = UIButton()
    private let gradientLayer = CAGradientLayer()
    private let pageIndicator = UIPageControl()
    private let pageController = UIPageViewController(transitionStyle: .scroll,
                                                      navigationOrientation: .horizontal)
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
        buttonConfig.title = "Continue"
        buttonConfig.baseBackgroundColor = .buttonBlue
        buttonConfig.baseForegroundColor = .white
        buttonConfig.cornerStyle = .medium
        button.configuration = buttonConfig
        view.addSubview(pageIndicator)
        pageIndicator.numberOfPages = 4
        view.addSubview(button)
        addChild(pageController)
        view.addSubview(pageController.view)
        pageController.didMove(toParent: self)
        pageController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        [button, pageIndicator, pageController.view].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate(buttonConstraints + pageIndicatorConstraints + pageControllerConstraints)
        pageIndicator.addTarget(self, action: #selector(didChangePage), for: .valueChanged)
        viewModel.pageIndex.assign(to: \.currentPage, on: pageIndicator).store(in: &bag)
        viewModel.isButtonEnabled.sink(receiveValue: { [button] in
            button.alpha = $0 ? 1 : 0.3
        }).store(in: &bag)
        viewModel.buttonTitle.sink(receiveValue: { [button] in
            button.setTitle($0, for: .normal)
        }).store(in: &bag)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        let controller = WelcomeTableController(viewModel.welcomeSnapshots)
        pageController.setViewControllers([controller], direction: .forward, animated: false)
        viewModel.screenUpdates.sink(receiveValue: { [pageController] in
            let newController = OnboardingTableController(Just($0).eraseToAnyPublisher())
            pageController.setViewControllers([newController], direction: .forward, animated: true)
        }).store(in: &bag)
    }
    
    required init?(coder: NSCoder) { fatalError() }

    public override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.layer.bounds
    }

    @objc private func didChangePage() {
        print("Page changed: \(pageIndicator.currentPage)")
    }

    @objc private func didTapButton() {
        viewModel.didTapButton()
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
         pageController.view.bottomAnchor.constraint(equalTo: button.topAnchor),
         //pageController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
         pageController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
         pageController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)]
    }
}


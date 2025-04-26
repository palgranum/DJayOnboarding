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
    var welcomeSnapshots: AnyPublisher<WelcomeTableSnap, Never> { get }
}

final public class OnboardingController: UIViewController {
    private let button = UIButton()
    private let gradientLayer = CAGradientLayer()
    private let pageIndicator = UIPageControl()
    private let navController = UINavigationController()
    private let viewModel: OnboardingViewModelType
    private var bag = Set<AnyCancellable>()

    init(_ viewModel: OnboardingViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        view.directionalLayoutMargins.leading = 32
        view.directionalLayoutMargins.trailing = 32
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
        pageIndicator.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        navController.view.translatesAutoresizingMaskIntoConstraints = false
        navController.isNavigationBarHidden = true
        view.addSubview(button)
        addChild(navController)
        view.addSubview(navController.view)
        navController.didMove(toParent: self)
        NSLayoutConstraint.activate(buttonConstraints + pageIndicatorConstraints + navigatorConstraints)
        pageIndicator.addTarget(self, action: #selector(didChangePage), for: .valueChanged)
        viewModel.pageIndex.assign(to: \.currentPage, on: pageIndicator).store(in: &bag)
        viewModel.isButtonEnabled.sink(receiveValue: { [button] in
            button.alpha = $0 ? 1 : 0.3
        }).store(in: &bag)
        viewModel.buttonTitle.sink(receiveValue: { [button] in
            button.setTitle($0, for: .normal)
        }).store(in: &bag)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        let controller = WelcomeController(viewModel.welcomeSnapshots)
        navController.pushViewController(controller, animated: false)
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

private extension OnboardingController {
    var buttonConstraints: [NSLayoutConstraint] {
        [button.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
         button.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
         button.bottomAnchor.constraint(equalTo: pageIndicator.topAnchor, constant: -8),
         button.heightAnchor.constraint(equalToConstant: 44)]
    }

    var pageIndicatorConstraints: [NSLayoutConstraint] {
        [pageIndicator.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
         pageIndicator.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -8)]
    }

    var navigatorConstraints: [NSLayoutConstraint] {
        [navController.view.topAnchor.constraint(equalTo: view.topAnchor),
         navController.view.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -8),
         navController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
         navController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)]
    }
}

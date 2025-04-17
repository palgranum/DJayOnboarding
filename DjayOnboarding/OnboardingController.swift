//
//  OnboardingController.swift
//  DjayOnboarding
//
//  Created by Pal Granum on 16/04/2025.
//

import UIKit

final public class OnboardingController: UIViewController {
    private let button = UIButton(type: .system)
    private let gradientLayer = CAGradientLayer()
    private let pageIndicator = UIPageControl()
    private let navController = UINavigationController()

    init() {
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
    }
    
    required init?(coder: NSCoder) { fatalError() }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.layer.bounds
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

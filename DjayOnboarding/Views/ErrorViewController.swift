//
//  ErrorViewController.swift
//  DjayOnboarding
//
//  Created by Pal Granum on 29/04/2025.
//

import UIKit

/// A simple view controller that displays an error message.
final public class ErrorViewController: UIViewController {
    private let label = UILabel()

    init(_ errorMessage: String) {
        super.init(nibName: nil, bundle: nil)
        view.addSubviewWithAutoLayout(label)
        label.text = errorMessage
        label.textColor = .red
        label.font = .systemFont(ofSize: 22, weight: .regular)
        NSLayoutConstraint.activate(
            [label.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
             label.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
             label.centerYAnchor.constraint(equalTo: view.centerYAnchor)])
    }

    required init?(coder: NSCoder) { fatalError() }
}

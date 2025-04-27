//
//  SkillSelectionCell.swift
//  DjayOnboarding
//
//  Created by Pal Granum on 26/04/2025.
//

import UIKit
import Combine

public protocol SkillSelectionViewModelType {
    var selectedButtonIndex: AnyPublisher<Int?, Never> { get }
    func didTapButton(at index: Int)
}

final class SkillSelectionCell: UITableViewCell {
    private let icon = UIImageView(image: UIImage(named: "icon"))
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let labelView = UIView()
    private let buttonStack: UIStackView
    private let viewModel: SkillSelectionViewModelType
    private var token: AnyCancellable?

    init(_ viewModel: SkillSelectionViewModelType) {
        self.viewModel = viewModel
        let buttonTitles = ["I’m new to DJing", "I’ve used DJ apps before", "I’m a professional DJ"]
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .white.withAlphaComponent(0.1)
        config.baseForegroundColor = .white
        config.background.strokeColor = .buttonBlue
        config.cornerStyle = .medium
        config.imagePadding = 10
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0)
        let font = UIFont.systemFont(ofSize: 17, weight: .regular)
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .kern: -0.44]
        let circleImage = UIImage.circle(diameter: 18, color: .selectionGray)
            .withAddedPadding(2)
        let buttons = buttonTitles.enumerated().map { index, title in
            config.attributedTitle = AttributedString(title,
                                                      attributes: AttributeContainer(attributes))
            let button = UIButton(type: .system)
            button.contentHorizontalAlignment = .leading
            button.configuration = config
            
            // Update handler to change appearance when selected
            button.configurationUpdateHandler = { button in
                guard var config = button.configuration else { return }
                if button.isSelected {
                    config.background.strokeWidth = 2
                    config.image = UIImage(named: "check")
                } else {
                    config.background.strokeWidth = 0
                    config.image = circleImage
                }
                button.configuration = config
            }
            return button
        }
        buttonStack = UIStackView(arrangedSubviews: buttons)
        super.init(style: .default, reuseIdentifier: nil)
        buttons.forEach {
            $0.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        }
        backgroundColor = .clear
        buttonStack.axis = .vertical
        buttonStack.spacing = 10
        buttonStack.distribution = .fillEqually
        titleLabel.textAlignment = .center
        titleLabel.attributedText = NSAttributedString(
            string: "Welcome DJ",
            attributes: [.font: UIFont.systemFont(ofSize: 34, weight: .bold),
                         .foregroundColor: UIColor.white,
                         .kern: 34 * 0.02])
        subtitleLabel.textAlignment = .center
        subtitleLabel.attributedText = NSAttributedString(
            string: "What’s your DJ skill level?",
            attributes: [.font: UIFont.systemFont(ofSize: 22, weight: .regular),
                         .foregroundColor: UIColor.white.withAlphaComponent(0.6),
                         .kern: 22 * 0.02])
        [titleLabel, subtitleLabel].forEach { [labelView] in
            $0.translatesAutoresizingMaskIntoConstraints = false
            labelView.addSubview($0)
        }
        labelView.addSubview(titleLabel)
        labelView.addSubview(subtitleLabel)
        [icon, labelView, buttonStack].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        NSLayoutConstraint.activate(iconConstraints
                                    + labelViewConstraints
                                    + buttonStackConstraints
                                    + titleLabelConstraints
                                    + subtitleLabelConstraints)
        token = viewModel.selectedButtonIndex.sink { [buttons] selectedIndex in
            buttons.enumerated().forEach { index, button in
                button.isSelected = index == selectedIndex
            }
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    @objc private func didTapButton(_ button: UIButton) {
        guard let index = buttonStack.arrangedSubviews.firstIndex(of: button) else { return }
        viewModel.didTapButton(at: index)
    }
}

private extension SkillSelectionCell {
    var iconConstraints: [NSLayoutConstraint] {
        [icon.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
         icon.widthAnchor.constraint(equalToConstant: 80),
         icon.heightAnchor.constraint(equalToConstant: 80),
         icon.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)]
    }

    var labelViewConstraints: [NSLayoutConstraint] {
        [labelView.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 32),
         labelView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
         labelView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
         labelView.heightAnchor.constraint(equalToConstant: 72)]
    }

    var titleLabelConstraints: [NSLayoutConstraint] {
        [titleLabel.topAnchor.constraint(equalTo: labelView.topAnchor),
         titleLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
         titleLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor)]
    }

    var subtitleLabelConstraints: [NSLayoutConstraint] {
        [subtitleLabel.bottomAnchor.constraint(equalTo: labelView.bottomAnchor),
         subtitleLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
         subtitleLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor)]
    }

    var buttonStackConstraints: [NSLayoutConstraint] {
        [buttonStack.topAnchor.constraint(equalTo: labelView.bottomAnchor, constant: 32),
         buttonStack.centerXAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerXAnchor),
         buttonStack.widthAnchor.constraint(equalToConstant: OnboardingController.buttonWidth),
         buttonStack.heightAnchor.constraint(equalToConstant: 164)]
    }
}

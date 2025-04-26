//
//  WelcomeController.swift
//  DjayOnboarding
//
//  Created by Pal Granum on 17/04/2025.
//

import UIKit
import Combine

public enum WelcomeTableItem: Int, Hashable {
    case logo
    case info

    var height: CGFloat {
        switch self {
        case .logo: 96
        case .info: 376
        }
    }
}

public typealias WelcomeTableSnap = NSDiffableDataSourceSnapshot<Int, WelcomeTableItem>

final class WelcomeController: UIViewController {
    private let tableView = UITableView()
    private var dataSource: UITableViewDiffableDataSource<Int, WelcomeTableItem>!
    private var token: AnyCancellable?
    private let welcomeLabel = UILabel()

    init(_ snapshots: AnyPublisher<WelcomeTableSnap, Never>) {
        super.init(nibName: nil, bundle: nil)
        view.addSubview(tableView)
        tableView.backgroundColor = .clear
        tableView.sectionHeaderTopPadding = 0
        tableView.delegate = self
        tableView.allowsSelection = false
        self.dataSource = UITableViewDiffableDataSource<Int, WelcomeTableItem>(tableView: tableView) { tableView, indexPath, item in
            switch item {
            case .logo: LogoCell()
            case .info: InfoCell()
            }
        }
        dataSource.defaultRowAnimation = .bottom
        var isAnimated = false
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
        token = snapshots.sink { [weak self] in
            self?.dataSource?.apply($0, animatingDifferences: isAnimated)
            self?.updateWelcomeLabel($0.itemIdentifiers.count > 1, isAnimated: isAnimated)
            self?.updateContentInset(isAnimated)
            isAnimated = true
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        updateContentInset(false)
        updateWelcomeLabel(dataSource.snapshot().itemIdentifiers.count > 1, isAnimated: false)
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

    private class LogoCell: UITableViewCell {
        private let image: UIImageView
        
        init() {
            self.image = UIImageView(image: UIImage(named: "djayLogo"))
            super.init(style: .default, reuseIdentifier: nil)
            image.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(image)
            backgroundColor = .clear
            NSLayoutConstraint.activate(imageConstraints)
        }

        required init?(coder: NSCoder) { fatalError() }
        
        private var imageConstraints: [NSLayoutConstraint] {
            [image.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
             image.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)]
        }
    }

    private final class InfoCell: UITableViewCell {
        private let devicesImage: UIImageView = UIImageView(image: UIImage(named: "devices"))
        private let adaImage: UIImageView = UIImageView(image: UIImage(named: "adaLogo"))
        private let label = UILabel()

        init() {
            super.init(style: .default, reuseIdentifier: nil)
            backgroundColor = .clear
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 34, weight: .bold)
            label.textColor = .white
            label.numberOfLines = 2
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            paragraphStyle.minimumLineHeight = 38
            paragraphStyle.maximumLineHeight = 38

            let attributedText = NSAttributedString(
                string: "Mix Your\nFavorite Music",
                attributes: [.kern: 0.02 * 34, .paragraphStyle: paragraphStyle]
            )
            label.attributedText = attributedText
            [devicesImage, adaImage, label].forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
                contentView.addSubview($0)
            }
            NSLayoutConstraint.activate(devicesImageConstraints + adaImageConstraints + labelConstraints)
            setComponentsScale(0.5)
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: { [weak self] in
                self?.setComponentsScale(1)
            })
        }

        required init?(coder: NSCoder) { fatalError() }

        private func setComponentsScale(_ scale: CGFloat) {
            [label, devicesImage, adaImage].forEach {
                $0.transform = .init(scaleX: scale, y: scale)
            }
        }

        private var devicesImageConstraints: [NSLayoutConstraint] {
            [devicesImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
             devicesImage.heightAnchor.constraint(equalToConstant: 140),
             devicesImage.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
             devicesImage.widthAnchor.constraint(equalToConstant: 310)]
        }

        private var adaImageConstraints: [NSLayoutConstraint] {
            [adaImage.centerYAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -48),
             adaImage.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)]
        }

        private var labelConstraints: [NSLayoutConstraint] {
            [label.topAnchor.constraint(equalTo: devicesImage.bottomAnchor, constant: 32),
             label.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
             label.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor)]
        }
    }
}

extension WelcomeController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        WelcomeTableItem(rawValue: indexPath.row)?.height ?? 0
    }
}

//
//  DJayInfoCell.swift
//  DjayOnboarding
//
//  Created by Pal Granum on 26/04/2025.
//

import UIKit

final class DJayInfoCell: UITableViewCell {
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

        // When first appearing, the components are scaled up to size:
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

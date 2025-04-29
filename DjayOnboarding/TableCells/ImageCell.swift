//
//  ImageCell.swift
//  DjayOnboarding
//
//  Created by Pal Granum on 26/04/2025.
//

import UIKit

/// A simple cell that contains a centered image.
final class ImageCell: UITableViewCell {
    private let imgView: UIImageView
    
    init(_ image: UIImage) {
        self.imgView = UIImageView(image: image)
        super.init(style: .default, reuseIdentifier: nil)
        contentView.addSubviewWithAutoLayout(imgView)
        backgroundColor = .clear
        NSLayoutConstraint.activate(imageConstraints)
    }

    required init?(coder: NSCoder) { fatalError() }
    
    private var imageConstraints: [NSLayoutConstraint] {
        [imgView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
         imgView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)]
    }
}


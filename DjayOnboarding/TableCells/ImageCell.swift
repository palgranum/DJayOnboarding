//
//  ImageCell.swift
//  DjayOnboarding
//
//  Created by Pal Granum on 26/04/2025.
//

import UIKit

final class ImageCell: UITableViewCell {
    private let imgView: UIImageView
    
    init(_ image: UIImage) {
        self.imgView = UIImageView(image: image)
        super.init(style: .default, reuseIdentifier: nil)
        imgView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imgView)
        backgroundColor = .clear
        NSLayoutConstraint.activate(imageConstraints)
    }

    required init?(coder: NSCoder) { fatalError() }
    
    private var imageConstraints: [NSLayoutConstraint] {
        [imgView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
         imgView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)]
    }
}


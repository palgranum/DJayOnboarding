//
//  UIView.swift
//  DjayOnboarding
//
//  Created by Pal Granum on 29/04/2025.
//

import UIKit

public extension UIView {
    func addSubviewWithAutoLayout(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
    }
}


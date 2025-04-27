//
//  UIImage_Ext.swift
//  DjayOnboarding
//
//  Created by Pal Granum on 27/04/2025.
//

import UIKit

public extension UIImage {
    static func circle(diameter: CGFloat, color: UIColor) -> UIImage {
        let strokeWidth: CGFloat = 2
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: diameter + strokeWidth,
                                                            height: diameter + strokeWidth))
        return renderer.image { context in
            let rect = CGRect(origin: .init(x: 0.5 * strokeWidth, y: 0.5 * strokeWidth),
                              size: CGSize(width: diameter, height: diameter))
            context.cgContext.setStrokeColor(color.cgColor)
            context.cgContext.setLineWidth(strokeWidth)
            context.cgContext.strokeEllipse(in: rect)
        }
    }

    func withAddedPadding(_ value: CGFloat) -> UIImage {
        UIGraphicsImageRenderer(size: CGSize(width: size.width + 2 * value,
                                             height: size.height + 2 * value)).image { context in
            let rect = CGRect(origin: .init(x: value, y: value),
                              size: self.size)
            self.draw(in: rect)
        }
    }
}

//
//  CGPoint_Ext.swift
//  DjayOnboarding
//
//  Created by Pal Granum on 28/04/2025.
//

import Foundation

public extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        sqrt(pow((point.x - x), 2) + pow((point.y - y), 2))
    }

    func angle(to point: CGPoint) -> CGFloat {
        atan2(point.y - self.y, point.x - self.x)
    }
}

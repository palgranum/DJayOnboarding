//
//  OnboardingTableItem.swift
//  DjayOnboarding
//
//  Created by Pal Granum on 26/04/2025.
//

import UIKit
import Combine

public typealias OnboardingTableSnapshot = NSDiffableDataSourceSnapshot<Int, OnboardingTableItem>

public enum OnboardingTableItem {
    case djayLogo
    case info
    case skillSelection(SkillSelectionViewModelType)

    var height: CGFloat {
        switch self {
        case .djayLogo: 96
        case .info: 376
        case .skillSelection: 412
        }
    }
}

extension OnboardingTableItem: Equatable {
    public static func == (lhs: OnboardingTableItem, rhs: OnboardingTableItem) -> Bool {
        switch (lhs, rhs) {
        case (.djayLogo, .djayLogo): return true
        case (.info, .info): return true
        case (.skillSelection, .skillSelection): return true
        default: return false
        }
    }
}

extension OnboardingTableItem: Hashable {
    public func hash(into hasher: inout Hasher) {
        let value = switch self {
        case .djayLogo: 0
        case .info: 1
        case .skillSelection: 2
        }
        hasher.combine(value)
    }
}

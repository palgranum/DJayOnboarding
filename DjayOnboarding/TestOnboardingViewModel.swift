//
//  TestOnboardingViewModel.swift
//  DjayOnboarding
//
//  Created by Pal Granum on 17/04/2025.
//

import Foundation
import Combine

public enum OnboardingState {
    case welcome
    case mix
    case skillSelection
    case ready

    var pageIndex: Int {
        switch self {
        case .welcome: 0
        case .mix: 1
        case .skillSelection: 2
        case .ready: 3
        }
    }
}

public enum DjaySkillLevel {
    case beginner
    case intermediate
    case professional
}

final class TestOnboardingViewModel: OnboardingViewModelType {
    private let stateSubject = CurrentValueSubject<OnboardingState, Never>(.welcome)
    private let skillSubject = CurrentValueSubject<DjaySkillLevel?, Never>(nil)

    func didTapButton() {
        switch stateSubject.value {
        case .welcome:
            stateSubject.send(.mix)
        case .mix:
            stateSubject.send(.skillSelection)
        case .skillSelection:
            stateSubject.send(.ready)
        case .ready:
            break
        }
    }

    var pageIndex: AnyPublisher<Int, Never> {
        stateSubject.map(\.pageIndex).eraseToAnyPublisher()
    }

    var buttonTitle: AnyPublisher<String, Never> {
        stateSubject.map { state in
            switch state {
            case .welcome, .mix: "Continue"
            case .skillSelection: "Let's go"
            case .ready: "Done"
            }
        }.eraseToAnyPublisher()
    }

    var isButtonEnabled: AnyPublisher<Bool, Never> {
        stateSubject.combineLatest(skillSubject).map { state, skill in
            guard state == .skillSelection else { return true }
            return skill != nil
        }.eraseToAnyPublisher()
    }
}

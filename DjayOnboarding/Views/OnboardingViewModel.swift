//
//  OnboardingViewModel.swift
//  DjayOnboarding
//
//  Created by Pal Granum on 17/04/2025.
//

import Foundation
import Combine

final class OnboardingViewModel: OnboardingViewModelType {
    private let stateSubject = CurrentValueSubject<OnboardingState, Never>(.welcome)
    private let skillSubject = CurrentValueSubject<DjaySkillLevel?, Never>(nil)

    private enum OnboardingState: Int {
        case welcome
        case info
        case skillSelection
        case congratulations
    }

    init() {
        try? AVAudioSession.sharedInstance().setMode(.default)
        try? AVAudioSession.sharedInstance().setCategory(.playback)
    }

    func didTapButton() {
        // Move ahead to the next state:
        switch stateSubject.value {
        case .welcome:
            stateSubject.send(.info)
        case .info:
            stateSubject.send(.skillSelection)
        case .skillSelection:
            stateSubject.send(.congratulations)
        case .congratulations:
            // We're just going to start over for the sake of this test:
            skillSubject.send(nil)
            stateSubject.send(.welcome)
        }
    }

    var pageIndex: AnyPublisher<Int, Never> {
        stateSubject.map(\.rawValue).eraseToAnyPublisher()
    }

    var buttonTitle: AnyPublisher<String, Never> {
        stateSubject.map { state in
            switch state {
            case .welcome, .info: "Continue"
            case .skillSelection: "Let's go"
            case .congratulations: "Done"
            }
        }.eraseToAnyPublisher()
    }

    var isButtonEnabled: AnyPublisher<Bool, Never> {
        stateSubject.combineLatest(skillSubject).map { state, skill in
            guard state == .skillSelection else { return true }
            return skill != nil
        }.eraseToAnyPublisher()
    }

    var screenUpdates: AnyPublisher<OnboardingScreen, Never> {
        stateSubject.compactMap { [weak self] in
            guard let self else { return nil }
            switch $0 {
            case .welcome:
                return .welcome(welcomeSnapshots)
            case .info:
                return nil
            case .skillSelection:
                let viewModel = SkillSelectionViewModel(skillSubject)
                return .skillSelection(viewModel)
            case .congratulations:
                guard let skill = skillSubject.value else { return nil }
                do {
                    let viewModel = try CongratulationsViewModel(skill)
                    return .congratulations(viewModel)
                } catch {
                    return .error(error)
                }
            }
        }.eraseToAnyPublisher()
    }

    private var welcomeSnapshots: AnyPublisher<OnboardingTableSnapshot, Never> {
        stateSubject.compactMap {
            var snap = OnboardingTableSnapshot()
            snap.appendSections([0])
            snap.appendItems([.djayLogo])
            switch $0 {
            case .welcome: return snap
            case .info:
                snap.appendItems([.info])
                return snap
            case .skillSelection, .congratulations: return nil
            }
        }.eraseToAnyPublisher()
    }
}

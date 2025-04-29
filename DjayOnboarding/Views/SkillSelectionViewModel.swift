//
//  SkillSelectionViewModel.swift
//  DjayOnboarding
//
//  Created by Pal Granum on 29/04/2025.
//

import Foundation
import Combine

final class SkillSelectionViewModel: SkillSelectionViewModelType {
    private let skillSubject: CurrentValueSubject<DjaySkillLevel?, Never>

    init(_ skillSubject: CurrentValueSubject<DjaySkillLevel?, Never>) {
        self.skillSubject = skillSubject
    }

    var selectedButtonIndex: AnyPublisher<Int?, Never> {
        skillSubject.map { $0?.rawValue }.eraseToAnyPublisher()
    }

    func didTapButton(at index: Int) {
        guard let skill = DjaySkillLevel(rawValue: index) else { return }
        skillSubject.send(skill)
    }
}

//
//  CongratulationsViewModel.swift
//  DjayOnboarding
//
//  Created by Pal Granum on 28/04/2025.
//

import Foundation
import AVFoundation

final class CongratulationsViewModel: CongratulationsViewModelType {
    let skillLevel: DjaySkillLevel
    let player: LoopPlayer
    
    init(_ skillLevel: DjaySkillLevel) throws {
        self.skillLevel = skillLevel
        self.player = try LoopPlayer()
        try player.startLoop()
    }

    func viewWillAppear() {
    }

    func viewWillDisappear() {
        player.stop()
    }

    func leftScope(_ nFrames: Int) -> UnsafePointer<Float> {
        player.scopeUnit.leftScope(nFrames)
    }

    func rightScope(_ nFrames: Int) -> UnsafePointer<Float> {
        player.scopeUnit.rightScope(nFrames)
    }

    func didStartPanning() {
        player.eqUnit.bands[0].bypass = false
        player.eqUnit.globalGain = 10
    }

    func didEndPanning() {
        player.eqUnit.bands[0].bypass = true
        player.eqUnit.globalGain = 0
    }

    func didUpdatePanPosition(_ normalizedPosition: CGPoint) {
        player.eqUnit.bands[0].frequency = 500 + Float(normalizedPosition.x * 9000)
        player.eqUnit.bands[0].bandwidth = Float(normalizedPosition.y * 5)
    }

    var messages: [String] {
        switch skillLevel {
        case .beginner:
            ["Welcome to the mix!",
             "Discover basic DJ skills with our guided tutorials.",
             "Learn to beat-match and create smooth transitions.",
             "Start with simple crossfades between your favorite tracks.",
             "Our interactive lessons make learning to DJ fun and easy.",
             "Experience the thrill of your first perfect mix.",
             "Build confidence with beginner-friendly controls.",
             "Explore basic effects to add flavor to your mixes.",
             "No experience needed - we'll guide you every step of the way.",
             "Tap 'Done' to begin your musical journey."]
        case .intermediate:
            ["Ready to elevate your skills?",
             "Access advanced mixing techniques and effects.",
             "Your personalized library awaits for more creative sessions.",
             "Master loop techniques and creative sample juggling.",
             "Dive into harmonic mixing and perfect your key transitions.",
             "Unlock advanced tempo manipulation and editing.",
             "Expand your toolkit with professional FX chains.",
             "Blend tracks like a pro with advanced techniques.",
             "Refine your unique sound with personalized presets."]
        case .professional:
            ["Studio-grade tools at your fingertips",
             "Customize your workflow, access premium samples, and connect with live streaming options.",
             "Fine-tune every parameter with precision automation.",
             "Seamlessly integrate with professional hardware controllers.",
             "Access exclusive sound packs from industry-leading producers.",
             "Create and share your own custom effect chains.",
             "Broadcast your sets with high-definition streaming integration.",
             "Multi-deck mixing with unlimited creative possibilities.",
             "Welcome to unrestricted creative control.",
             "Experience latency-free performance with our optimized audio engine."]
        }
    }
}

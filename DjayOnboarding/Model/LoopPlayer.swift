//
//  LoopPlayer.swift
//  DjayOnboarding
//
//  Created by Pal Granum on 29/04/2025.
//

import Foundation

enum PlayerError: Error {
    case missingResources
    case invalidFormat
    case noBuffer
}

/// An audio player based on AVAudioEngine that sets up a simple chain with a player, an eq node and a custom unit used for scope visualization.
final class LoopPlayer {
    private let engine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private let audioBuffer: AVAudioPCMBuffer
    let scopeUnit: ScopeUnit
    let eqUnit: AVAudioUnitEQ
    
    init() throws {
        let desc = AudioComponentDescription(componentType: kAudioUnitType_Effect,
                                             componentSubType: 9999,
                                             componentManufacturer: 9999,
                                             componentFlags: 0, componentFlagsMask: 0)
        AUAudioUnit.registerSubclass(ScopeUnit.self,
                                     as: desc, name: "Scoper",
                                     version: UInt32.max)
        let avScoper = AVAudioUnitEffect(audioComponentDescription: desc)
        self.scopeUnit = avScoper.auAudioUnit as! ScopeUnit
        eqUnit = AVAudioUnitEQ(numberOfBands: 1)
        eqUnit.bands[0].filterType = .resonantHighShelf
        eqUnit.bands[0].gain = -30
        guard let url = Bundle.main.url(forResource: "Amen-break", withExtension: "wav") else {
            throw PlayerError.missingResources
        }
        let file = try AVAudioFile(forReading: url)
        guard let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: file.fileFormat.sampleRate, channels: file.fileFormat.channelCount, interleaved: false) else {
            throw PlayerError.invalidFormat
        }
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(file.length)) else {
            throw PlayerError.noBuffer
        }
        try file.read(into: buffer)
        self.audioBuffer = buffer
        engine.attach(playerNode)
        engine.attach(eqUnit)
        engine.attach(avScoper)
        engine.connect(playerNode, to: eqUnit, format: buffer.format)
        engine.connect(eqUnit, to: avScoper, format: buffer.format)
        engine.connect(avScoper, to: engine.mainMixerNode, format: buffer.format)
    }

    func startLoop() throws {
        try engine.start()
        playerNode.scheduleBuffer(audioBuffer, at: nil, options: .loops)
        playerNode.play()
    }

    func stop() {
        playerNode.stop()
        engine.stop()
        engine.reset()
    }
}

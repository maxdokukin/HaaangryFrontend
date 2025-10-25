//
//  AudioSession.swift
//  HaaangryFrontend
//
//  Created by xewe on 10/25/25.
//

import Foundation
import AVFoundation

enum AudioSession {
    static func configurePlayback() {
        let s = AVAudioSession.sharedInstance()
        try? s.setCategory(.playback, mode: .moviePlayback, options: [])
        try? s.setActive(true)
    }
}

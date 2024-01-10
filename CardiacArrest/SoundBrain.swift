//
//  SoundBrain.swift
//  CardiacArrest
//
//  Created by James on 1/10/24.
//

import Foundation
import AVFoundation
import UIKit

struct SoundBrain {
    let soundDict: [String:String] = [
        // Sound Effect
        "Silence":"Silence"
    ,   "CPR":"WarningSound"
    ,   "EPI3":"OneDing"
    ,   "EPI4":"TwoDings"
    ,   "EPI5":"ThreeDings"
    ]
    
    var player: AVAudioPlayer?
    
    mutating func playSound(soundTitle: String) {
        let soundFile = soundDict[soundTitle]!
        
        guard let url = Bundle.main.url(forResource: soundFile, withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            guard let player = player else { return }
            
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

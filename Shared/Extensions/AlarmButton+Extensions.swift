//
//  AlarmButton.swift
//  ItsukiAlarm
//
//  Created by Itsuki on 2025/06/17.
//

import AlarmKit
import SwiftUI

extension AlarmButton {

    static var snoozeButton: Self {
        AlarmButton(text: "Snooze", textColor: .white, systemImageName: "moon.zzz")
    }

    static var pauseButton: Self {
        AlarmButton(text: "Pause", textColor: .alarmTint, systemImageName: "pause.fill")
    }
    
    static var resumeButton: Self {
        AlarmButton(text: "Resume", textColor: .alarmTint, systemImageName: "play.fill")
    }
    
    static var repeatButton: Self {
        AlarmButton(text: "Repeat", textColor: .white, systemImageName: "repeat")
    }
    
    static var stopButton: Self {
        AlarmButton(text: "Stop", textColor: .white, systemImageName: "xmark")
    }
}

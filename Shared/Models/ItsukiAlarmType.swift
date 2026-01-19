//
//  ItsukiAlarmType.swift
//  ItsukiAlarm
//
//  Created by Itsuki on 2025/06/17.
//

import SwiftUI

enum ItsukiAlarmType: CaseIterable {
    case alarm
    case timer
    case custom
    case recordings

    var title: String {
        switch self {
        case .alarm:
            return "Alarms"
        case .timer:
            return "Timers"
        case .custom:
            return "Customs"
        case .recordings:
            return "Recordings"
        }
    }

    var icon: String {
        switch self {
        case .alarm:
            return "alarm.fill"
        case .timer:
            return "timer"
        case .custom:
            return "scribble"
        case .recordings:
            return "waveform"
        }
    }

    var tabValue: Int {
        switch self {
        case .alarm:
            return 0
        case .timer:
            return 1
        case .custom:
            return 2
        case .recordings:
            return 3
        }
    }
}

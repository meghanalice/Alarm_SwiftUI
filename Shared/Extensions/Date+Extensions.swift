//
//  Date.swift
//  ItsukiAlarm
//
//  Created by Itsuki on 2025/06/20.
//

import SwiftUI
import AlarmKit

extension Date {
    var time: Alarm.Schedule.Relative.Time? {
        let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: self)
        guard let hour = dateComponents.hour, let minute = dateComponents.minute else { return nil }
        let time = Alarm.Schedule.Relative.Time(hour: hour, minute: minute)
        return time
    }
}


//
//  Alarm.swift
//  ItsukiAlarm
//
//  Created by Itsuki on 2025/06/20.
//

import AlarmKit
import SwiftUI


extension Alarm {
    var isFixedDate: Bool {
        guard let schedule else {
            return false
        }
        switch schedule {
        case .fixed(_):
            return true
        case .relative(_):
            return false
        @unknown default:
            return false
        }
    }
    
    var itsukiAlarmType: ItsukiAlarmType {
        return switch (self.countdownDuration, self.schedule) {
        case (nil, .some(_)):
            ItsukiAlarmType.alarm
        case (.some(_), nil):
            ItsukiAlarmType.timer
        default:
            ItsukiAlarmType.custom
        }
    }
    
    var isOneShot: Bool {
        guard let schedule else {
            return true
        }
        
        switch schedule {
        case .fixed(_):
            return true
        case .relative(let relative):
            switch relative.repeats {
            case .never:
                return true
            case .weekly(let weekdays):
                return weekdays.isEmpty
            @unknown default:
                return true
            }
         
        @unknown default:
            return true
        }
        
    }
    
    func alertingDate(createdAt: Date) -> Date? {
        guard let schedule else { return nil }
        
        switch schedule {
        case .fixed(let date):
            return date
        case .relative(let relative):
            let referenceTime = createdAt.time ?? .init(hour: 0, minute: 0)
            var referenceDate = createdAt
            if referenceTime.hour > relative.time.hour || (referenceTime.hour == relative.time.hour && referenceTime.minute >= relative.time.minute)  {
                referenceDate.addTimeInterval(60 * 60 * 24)
            }
            var components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: referenceDate)
            components.hour = relative.time.hour
            components.minute = relative.time.minute
            let date = Calendar.current.date(from: components)
            return date
        @unknown default:
            return nil
        }
    }
    
    var scheduledTime: Alarm.Schedule.Relative.Time? {
        guard let schedule, case .relative(let relative) = schedule else { return nil }
        return relative.time
    }
    
    var scheduledWeekdays: Set<Locale.Weekday>? {
        guard let schedule, case .relative(let relative) = schedule else { return nil }
        switch relative.repeats {
        case .weekly(let array):
            return Set(array)
        case .never:
            return []
        @unknown default:
            return nil
        }
    }
    
    var timerDuration: TimeInterval? {
        guard let countdownDuration else { return nil }
        return countdownDuration.preAlert
    }
    
    var snoozeDuration: TimeInterval? {
        guard let countdownDuration else { return nil }
        return countdownDuration.postAlert
    }

}


extension Alarm.ID {
    var widgetURL: URL? {
        URL(string: "itsukiAlarm://\(self)")
    }
}


extension Alarm.Schedule.Relative.Time {
    var formattedDigits: String {
        return String(format: "%0.2d:%0.2d", self.hour, self.minute)
    }
}


extension Alarm.State {
    var string: String {
        switch self {
        case .scheduled: "scheduled"
        case .countdown: "running"
        case .paused: "paused"
        case .alerting: "alerting"
        default: ""
        }
    }
    
    var badgeColor: Color {
        switch self {
        case .scheduled:
            Color.green
        case .alerting:
            Color.red
        default:
            Color.orange
        }
    }
}

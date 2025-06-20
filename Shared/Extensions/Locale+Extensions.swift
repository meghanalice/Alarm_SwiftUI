//
//  Locale.swift
//  ItsukiAlarm
//
//  Created by Itsuki on 2025/06/20.
//

import SwiftUI


extension Locale {
    var orderedWeekdays: [Locale.Weekday] {
        let days: [Locale.Weekday] = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
        if let firstDayIndex = days.firstIndex(of: firstDayOfWeek), firstDayIndex != 0 {
            return Array(days[firstDayIndex...] + days[0..<firstDayIndex])
        }
        return days
    }
}


extension Locale.Weekday {
    var fullSymbol: String {
        let calendar = Calendar.autoupdatingCurrent
        let weekdays = calendar.weekdaySymbols        
        return weekdays.first(where: {$0.localizedCaseInsensitiveContains(self.rawValue)}) ?? self.rawValue.localizedCapitalized
    }
}


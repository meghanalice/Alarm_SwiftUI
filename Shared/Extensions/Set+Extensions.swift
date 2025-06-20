//
//  Set.swift
//  ItsukiAlarm
//
//  Created by Itsuki on 2025/06/20.
//

import SwiftUI

extension Set where Element == Locale.Weekday {
    var stringRepresentation: String {
        if self.isEmpty {
            return "Never"
        }
        if self.count == 7 {
            return "Every day"
        }
        
        if self.count == 1, let first = self.first {
            return "Every \(first.fullSymbol)"
        }

        if self.count == 2, self == Set([.sunday, .saturday]) {
            return "Weekends"
        }
        
        if self.count == 5, self == Set([.monday, .tuesday, .wednesday, .thursday, .friday]) {
            return "Weekdays"
        }
            
        return self.map({$0.rawValue.localizedCapitalized}).joined(separator: ", ")
    }
}

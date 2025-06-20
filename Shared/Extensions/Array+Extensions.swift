//
//  Array.swift
//  ItsukiAlarm
//
//  Created by Itsuki on 2025/06/20.
//

import SwiftUI
import AlarmKit

extension Array where Element == ItsukiAlarm {
    var sorted: Array {
        return self.sorted(by: { one, two in
            guard let firstTime = one.scheduledTime, let secondTime = two.scheduledTime, firstTime != secondTime else {
                return one.createdAt < two.createdAt
            }

            return firstTime.hour < secondTime.hour || (firstTime.hour == secondTime.hour && firstTime.minute < secondTime.minute)
        })
    }
}

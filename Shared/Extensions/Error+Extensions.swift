//
//  Error.swift
//  ItsukiAlarm
//
//  Created by Itsuki on 2025/06/20.
//


import SwiftUI

extension Error {
    var message: String {
        if let error = self as? ItsukiAlarmManager._Error {
            return error.message
        }
        return self.localizedDescription
    }
}

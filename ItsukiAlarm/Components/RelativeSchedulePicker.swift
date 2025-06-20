//
//  RelativeSchedulePicker.swift
//  ItsukiAlarm
//
//  Created by Itsuki on 2025/06/20.
//

import SwiftUI

struct RelativeSchedulePicker: View {
    @Binding var date: Date
    var body: some View {
            DatePicker("", selection: $date, displayedComponents: .hourAndMinute)
                .labelsHidden()
    }
}

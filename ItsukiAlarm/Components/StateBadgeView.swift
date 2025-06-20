//
//  StateBadgeView.swift
//  ItsukiAlarm
//
//  Created by Itsuki on 2025/06/20.
//

import SwiftUI
import AlarmKit

struct StateBadgeView: View {
    var state: Alarm.State?
    
    var body: some View {
        Group {
            if let state {
                Text(state.string)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 4)
                    .background(RoundedRectangle(cornerRadius: 4).fill(state.badgeColor))
            } else {
                EmptyView()
            }
            
        }
    }
}

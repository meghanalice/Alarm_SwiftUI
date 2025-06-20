//
//  TimerDigitsView.swift
//  ItsukiAlarm
//
//  Created by Itsuki on 2025/06/20.
//

import SwiftUI
import AlarmKit

struct TimerDigitsView: View {
    var totalDuration: TimeInterval?
    var presentationMode: AlarmPresentationState.Mode?

    var body: some View {
        Group {
            switch presentationMode {
            case .countdown(let countdown):
                let remaining = countdown.totalCountdownDuration - countdown.previouslyElapsedDuration
                Text(timerInterval: countdown.startDate...countdown.startDate.addingTimeInterval(remaining), countsDown: true, showsHours: true)
                    
            case .paused(let pause):
                let remaining = pause.totalCountdownDuration - pause.previouslyElapsedDuration
                Text(remaining.formattedDigits)
                
            // alerting
            case .alert(_):
                Text(0.formattedDigits)
            
            case nil:
                if let totalDuration {
                    Text(totalDuration.formattedDigits)
                } else {
                    EmptyView()
                }
            default:
                EmptyView()
            }
        }
        .monospacedDigit()
        .lineLimit(1)
        .minimumScaleFactor(0.6)

    }
}

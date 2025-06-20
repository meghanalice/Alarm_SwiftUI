//
//  CustomCellView.swift
//  ItsukiAlarm
//
//  Created by Itsuki on 2025/06/20.
//

import SwiftUI
import AlarmKit

struct CustomCellView: View {
    @Environment(ItsukiAlarmManager.self) private var alarmManager
    
    var alarmId: Alarm.ID
    var metadata: _AlarmMetadata
    var schedule: Alarm.Schedule
    var countdownDuration: Alarm.CountdownDuration
    
    @State var enabled: Bool
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Group {
                    switch schedule {
                    case .fixed(let date):
                        HStack {
                            Text(date, style: .date)
                            Text(date, style: .time)
                        }
                    case .relative(let relative):
                        let time = relative.time
                        Text(time.formattedDigits)
                            .monospacedDigit()
                        
                    @unknown default:
                        EmptyView()
                    }
                }
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .font(.system(size: 40, design: .rounded))


                HStack(spacing: 0) {
                    let title = metadata.title
                    let icon = metadata.icon
                    
                    Text("\(Image(systemName: icon.rawValue)) \(title.isEmpty ? _AlarmMetadata.customDefaultMetadata.title : title)")

                    if case .relative(let relative) = schedule {
                        let selectedWeekdays: Set<Locale.Weekday> = if case .weekly(let weekdays) = relative.repeats {
                            Set(weekdays)
                        } else { [] }
                        
                        if !selectedWeekdays.isEmpty {
                            Text(", \(selectedWeekdays.stringRepresentation)")
                        }
                    }
                }
                .font(.system(size: 16))
                .padding(.leading, 8)

            
                HStack {
                    if let preAlert = countdownDuration.preAlert {
                        Text("Countdown: \(preAlert.formattedDigits)")
                    }
                    if let postAlert = countdownDuration.postAlert {
                        Text("Snooze: \(postAlert.formattedDigits)")
                    }
                }
                .font(.system(size: 16))
                .padding(.leading, 8)
                .minimumScaleFactor(0.6)

                
            }
            .foregroundStyle(enabled ? Color.primary : .gray)
            .frame(maxWidth: .infinity, alignment: .leading)

            Toggle(isOn: $enabled, label: {})
                .labelsHidden()
                .onChange(of: enabled, {
                    Task {
                        do {
                            try await self.alarmManager.toggleCustom(self.alarmId)
                        } catch(let error) {
                            alarmManager.error = error
                        }
                    }
                })
        }

    }
}

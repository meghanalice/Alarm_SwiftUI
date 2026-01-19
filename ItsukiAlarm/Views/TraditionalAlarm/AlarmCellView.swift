//
//  AlarmCellView.swift
//  ItsukiAlarm
//
//  Created by Itsuki on 2025/06/20.
//

import AlarmKit
import SwiftUI

struct AlarmCellView: View {
    @Environment(ItsukiAlarmManager.self) private var alarmManager

    var alarmId: Alarm.ID
    var metadata: _AlarmMetadata
    var selectedWeekdays: Set<Locale.Weekday>
    var scheduledTime: Alarm.Schedule.Relative.Time

    @State var enabled: Bool
    @State private var showRecorder = false
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(scheduledTime.formattedDigits)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .font(.system(size: 40, design: .rounded))

                HStack(spacing: 0) {
                    let title = metadata.title
                    let icon = metadata.icon

                    Text(
                        "\(Image(systemName: icon.rawValue)) \(title.isEmpty ? _AlarmMetadata.alarmDefaultMetadata.title : title)"
                    )
                    .padding(.leading, 8)

                    if !selectedWeekdays.isEmpty {
                        Text(", \(selectedWeekdays.stringRepresentation)")
                    }
                }
                .font(.system(size: 16))
            }
            .foregroundStyle(enabled ? Color.primary : .gray)
            .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: {
                showRecorder = true
            }) {
                Image(systemName: "mic.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundStyle(.blue)
            }
            .buttonStyle(PlainButtonStyle())
            .sheet(isPresented: $showRecorder) {
                VoiceRecorderView(
                    alarmTitle: metadata.title.isEmpty
                        ? _AlarmMetadata.alarmDefaultMetadata.title : metadata.title)
            }

            Toggle(isOn: $enabled, label: {})
                .labelsHidden()
                .onChange(
                    of: enabled,
                    {
                        Task {
                            do {
                                try await self.alarmManager.toggleAlarm(self.alarmId)
                            } catch (let error) {
                                alarmManager.error = error

                            }
                        }
                    })
        }

    }
}

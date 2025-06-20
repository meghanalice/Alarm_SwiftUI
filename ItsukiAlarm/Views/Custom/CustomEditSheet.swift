//
//  CustomEditSheet.swift
//  ItsukiAlarm
//
//  Created by Itsuki on 2025/06/20.
//

import SwiftUI
import AlarmKit


extension CustomEditSheet {
    init(alarm: ItsukiAlarm) {
        self.alarmId = alarm.id
        self.date = alarm.alarm.alertingDate(createdAt: alarm.createdAt) ?? Date()
        self.selectedWeekdays = alarm.scheduledWeekdays ?? []
        self.alarmTitle = alarm.title
        self.alarmIcon = alarm.icon
        
        let hms = alarm.timerDuration?.hms
        self.hour = hms?.0 ?? 0
        self.min = hms?.1 ?? 0
        self.sec = hms?.2 ?? 0
        
        self.isFixedDate = alarm.isFixedDate
        let snoozeDuration = alarm.snoozeDuration
        let snoozeHms = snoozeDuration?.hms
        self.snoozeHour = snoozeHms?.0 ?? 0
        self.snoozeSec = snoozeHms?.1 ?? 0
        self.snoozeMin = snoozeHms?.2 ?? 0

    }
    
    init() {
        self.date = Date()
        self.selectedWeekdays = []
        self.alarmTitle = _AlarmMetadata.customDefaultMetadata.title
        self.alarmIcon = _AlarmMetadata.customDefaultMetadata.icon
        self.hour = 0
        self.min = 0
        self.sec = 0
        self.isFixedDate = false
        self.snoozeHour = 0
        self.snoozeSec = 0
        self.snoozeMin = 0

    }
}

struct CustomEditSheet: View {
    private var alarmId: Alarm.ID?
    
    @Environment(ItsukiAlarmManager.self) private var alarmManager
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var isFixedDate: Bool
    
    @State private var date: Date
    @State private var selectedWeekdays: Set<Locale.Weekday>
    
    @State private var hour: Int
    @State private var min: Int
    @State private var sec: Int
    
    
    @State private var alarmTitle: String
    @State private var alarmIcon: _AlarmMetadata.Icon
    
    @State private var snoozeHour: Int
    @State private var snoozeMin: Int
    @State private var snoozeSec: Int


    var body: some View {
        let countdown: TimeInterval = .hms(hour, min, sec)
        let snooze: TimeInterval = .hms(snoozeHour, snoozeMin, snoozeSec)
        
        NavigationStack {
            Form {
                Section {
                    Text("Either a non-zero **Countdown** or a non-zero **Snooze** time is required.")
                        .font(.headline)
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.leading)
                        .minimumScaleFactor(0.7)
                        .listRowBackground(Color.clear)
                }
                .listSectionMargins([.top, .bottom], 0)
                
                Section {
                    HStack {
                        Text("Fixed Date")
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Toggle(isOn: $isFixedDate, label: {})
                            .labelsHidden()
                    }
                    
                    HStack {
                        Text("Schedule")
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Group {
                            if !isFixedDate {
                                RelativeSchedulePicker(date: $date)
                            } else {
                                FixedSchedulePicker(date: $date)
                            }
                        }
                        .datePickerStyle(.compact)
                    }
                    
                    if !isFixedDate {
                        NavigationLink(destination: {
                            WeekdayPicker(selectedWeekdays: $selectedWeekdays)
                        }, label: {
                            HStack {
                                Text("Repeat")
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Text(selectedWeekdays.stringRepresentation)
                                    .foregroundStyle(.gray)
                            }
                        })
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Countdown")

                        TimerDurationPicker(hour: $hour, min: $min, sec: $sec)
                    }

                    
                    MetadataEntryView(title: $alarmTitle, icon: $alarmIcon)
                    
                    
                    HStack {
                        VStack(alignment: .leading) {
                            
                            Text("Snooze")
                                .frame(maxWidth: .infinity, alignment: .leading)

                            TimerDurationPicker(hour: $snoozeHour, min: $snoozeMin, sec: $snoozeSec)
                            
                        }

                    }

                    
                }
                
                if let alarmId {
                    Button(action: {
                        do {
                            try self.alarmManager.deleteAlarm(alarmId)
                            self.dismiss()
                        } catch(let error) {
                            alarmManager.error = error
                        }
                    }, label: {
                        Text("Delete Custom")
                            .foregroundStyle(.red)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .contentShape(Rectangle())
                    })

                }

            }
            .navigationTitle(self.alarmId == nil ? "Add Custom" : "Edit Custom")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading, content: {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Text("Cancel")
                    })
                    .foregroundStyle(Color.alarmTint)

                })
                
                ToolbarItem(placement: .topBarTrailing, content: {
                    Button(action: {
                        Task {
                            do {
                                if let alarmId {
                                    try await self.alarmManager.editCustom(alarmId, title: self.alarmTitle, icon: self.alarmIcon, isFixedDate: self.isFixedDate, date: self.date, repeats: self.selectedWeekdays, countdown: countdown, snooze: snooze)

                                } else {
                                    try await self.alarmManager.addCustom(self.alarmTitle, icon: self.alarmIcon, isFixedDate: self.isFixedDate, date: self.date, repeats: self.selectedWeekdays, countdown: countdown, snooze: snooze)
                                }
                                dismiss()
                            } catch (let error) {
                                alarmManager.error = error
                            }
                        }
                    }, label: {
                        Text("Save")
                            .fontWeight(.semibold)
                    })
                    .foregroundStyle(Color.alarmTint.opacity(countdown == 0 && snooze == 0 ? 0.3 : 1.0))
                    .disabled(countdown == 0 && snooze == 0)


                })
            })
        }
    }
}


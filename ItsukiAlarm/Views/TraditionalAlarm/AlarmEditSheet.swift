//
//  AlarmEditSheet.swift
//  ItsukiAlarm
//
//  Created by Itsuki on 2025/06/20.
//

import SwiftUI
import AlarmKit

extension AlarmEditSheet {
    init(alarm: ItsukiAlarm) {
        self.alarmId = alarm.id
        self.date = alarm.alarm.alertingDate(createdAt: alarm.createdAt) ?? Date()
        self.selectedWeekdays = alarm.scheduledWeekdays ?? []
        self.alarmTitle = alarm.title
        self.alarmIcon = alarm.icon
    }
    
    init() {
        self.date = Date()
        self.selectedWeekdays = []
        self.alarmTitle = _AlarmMetadata.alarmDefaultMetadata.title
        self.alarmIcon = _AlarmMetadata.alarmDefaultMetadata.icon
    }
}

struct AlarmEditSheet: View {
    private var alarmId: Alarm.ID?
    
    @Environment(ItsukiAlarmManager.self) private var alarmManager
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var date: Date
    @State private var selectedWeekdays: Set<Locale.Weekday>
    
    @State private var alarmTitle: String
    @State private var alarmIcon: _AlarmMetadata.Icon

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    RelativeSchedulePicker(date: $date)
                        .datePickerStyle(.wheel)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(.all, 0)
                
                Section {
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
                    
                    MetadataEntryView(title: $alarmTitle, icon: $alarmIcon)

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
                        Text("Delete Alarm")
                            .foregroundStyle(.red)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .contentShape(Rectangle())
                    })

                }

            }
            .navigationTitle(self.alarmId == nil ? "Add Alarm" : "Edit Alarm")
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
                                    try await self.alarmManager.editAlarm(alarmId, title: self.alarmTitle, icon: self.alarmIcon, date: self.date, repeats: self.selectedWeekdays)

                                } else {
                                    try await self.alarmManager.addAlarm(self.alarmTitle, icon: self.alarmIcon, date: self.date, repeats: self.selectedWeekdays)
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
                    .foregroundStyle(Color.alarmTint)


                })
            })
        }
    }
}



//
//  AlarmListView.swift
//  ItsukiAlarm
//
//  Created by Itsuki on 2025/06/20.
//

import SwiftUI
import AlarmKit

struct AlarmListView: View {
    @Environment(ItsukiAlarmManager.self) private var alarmManager: ItsukiAlarmManager

    @State private var showNewAlarmSheet: Bool = false
    
    var body: some View {
        
        List {
            Section {
                ForEach(self.alarmManager.runningTraditionalAlarms) { alarm in
                    NavigationLink(destination: {
                        AlarmEditSheet(alarm: alarm)
                            .environment(self.alarmManager)
                    }, label: {
                        AlarmCellView(
                            alarmId: alarm.id,
                            metadata: alarm.metadata,
                            selectedWeekdays: alarm.scheduledWeekdays ?? [],
                            scheduledTime: alarm.scheduledTime ?? .init(hour: 0, minute: 0),
                            enabled: true
                        )
                    })
                    .navigationLinkIndicatorVisibility(.hidden)
                }
                .onDelete(perform: { indexSet in
                    self.delete(indexSet, in: alarmManager.runningTraditionalAlarms)
                })

            }
            
            Section(self.alarmManager.recentTraditionalAlarms.isEmpty ? "" : "Recent") {
                ForEach(self.alarmManager.recentTraditionalAlarms) { alarm in
                    NavigationLink(destination: {
                        AlarmEditSheet(alarm: alarm)
                            .environment(self.alarmManager)
                    }, label: {
                        AlarmCellView(
                            alarmId: alarm.id,
                            metadata: alarm.metadata,
                            selectedWeekdays: alarm.scheduledWeekdays ?? [],
                            scheduledTime: alarm.scheduledTime ?? .init(hour: 0, minute: 0),
                            enabled: false
                        )
                    })
                    .navigationLinkIndicatorVisibility(.hidden)
                }
                .onDelete(perform: { indexSet in
                    self.delete(indexSet, in: alarmManager.recentTraditionalAlarms)
                })

            }

        }
        .navigationTitle(ItsukiAlarmType.alarm.title)
        .navigationBarTitleDisplayMode(.large)
        .toolbar(content: {
            ToolbarItem(placement: .topBarLeading, content: {
                EditButton()
                    .foregroundStyle(Color.alarmTint)
            })
            
            ToolbarItem(placement: .topBarTrailing, content: {
                Button(action: {
                    self.showNewAlarmSheet = true
                }, label: {
                    Image(systemName: "plus")
                        .foregroundStyle(Color.alarmTint)
                })
                .aspectRatio(1, contentMode: .fit)
            })
        })
        .sheet(isPresented: $showNewAlarmSheet, content: {
            AlarmEditSheet()
        })
        .overlay(content: {
            if self.alarmManager.runningTraditionalAlarms.isEmpty && self.alarmManager.recentTraditionalAlarms.isEmpty {
                ContentUnavailableView("No Alarms", systemImage: "alarm.fill")
            }
        })


    }
    
    private func delete(_ indexSet: IndexSet, in array: [ItsukiAlarm]) {
        // not looping directly using indexSet because the index may change after deleting some
        let ids = indexSet.map({array[$0].id})
        for id in ids {
            do {
                try alarmManager.deleteAlarm(id)
            } catch(let error) {
                alarmManager.error = error
            }
        }

    }
}


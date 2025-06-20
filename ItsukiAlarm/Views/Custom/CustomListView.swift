//
//  CustomListView.swift
//  ItsukiAlarm
//
//  Created by Itsuki on 2025/06/20.
//


import SwiftUI
import AlarmKit

struct CustomListView: View {
    @Environment(ItsukiAlarmManager.self) private var alarmManager: ItsukiAlarmManager

    @State private var showNewCustomSheet: Bool = false
    
    var body: some View {
        
        List {
            Section {
                ForEach(self.alarmManager.runningCustomAlarms) { alarm in
                    NavigationLink(destination: {
                        CustomEditSheet(alarm: alarm)
                            .environment(self.alarmManager)
                    }, label: {
                        if let schedule = alarm.schedule, let countdown = alarm.countdownDuration {
                            CustomCellView(alarmId: alarm.id, metadata: alarm.metadata, schedule: schedule, countdownDuration: countdown, enabled: true)
                        }
                    })
                    .navigationLinkIndicatorVisibility(.hidden)
                }
                .onDelete(perform: { indexSet in
                    self.delete(indexSet, in: alarmManager.runningCustomAlarms)
                })

            }
            
            Section(self.alarmManager.recentCustomAlarms.isEmpty ? "" : "Recent") {
                ForEach(self.alarmManager.recentCustomAlarms) { alarm in
                    NavigationLink(destination: {
                        CustomEditSheet(alarm: alarm)
                            .environment(self.alarmManager)
                    }, label: {
                        if let schedule = alarm.schedule, let countdown = alarm.countdownDuration {
                            CustomCellView(alarmId: alarm.id, metadata: alarm.metadata, schedule: schedule, countdownDuration: countdown, enabled: false)
                        }
                    })
                    .navigationLinkIndicatorVisibility(.hidden)
                }
                .onDelete(perform: { indexSet in
                    self.delete(indexSet, in: alarmManager.recentCustomAlarms)
                })

            }

        }
        .navigationTitle(ItsukiAlarmType.custom.title)
        .navigationBarTitleDisplayMode(.large)
        .toolbar(content: {
            ToolbarItem(placement: .topBarLeading, content: {
                EditButton()
                    .foregroundStyle(Color.alarmTint)
            })
            
            ToolbarItem(placement: .topBarTrailing, content: {
                Button(action: {
                    self.showNewCustomSheet = true
                }, label: {
                    Image(systemName: "plus")
                        .foregroundStyle(Color.alarmTint)
                })
                .aspectRatio(1, contentMode: .fit)
            })
        })
        .sheet(isPresented: $showNewCustomSheet, content: {
            CustomEditSheet()
        })
        .overlay(content: {
            if self.alarmManager.runningCustomAlarms.isEmpty && self.alarmManager.recentCustomAlarms.isEmpty {
                ContentUnavailableView("No Customs", systemImage: "alarm.fill")
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


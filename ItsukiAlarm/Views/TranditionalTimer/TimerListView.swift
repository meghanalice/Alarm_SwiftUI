//
//  TimerListView.swift
//  ItsukiAlarm
//
//  Created by Itsuki on 2025/06/20.
//


import SwiftUI
import AlarmKit

struct TimerListView: View {
    @Environment(ItsukiAlarmManager.self) private var alarmManager: ItsukiAlarmManager

    @AppStorage("hour") private var hour: Int = 0
    @AppStorage("min") private var min: Int = 0
    @AppStorage("sec") private var sec: Int = 0
    @AppStorage("timerTitle") private var timerTitle: String = _AlarmMetadata.timerDefaultMetadata.title
    @AppStorage("timerIcon") private var timerIcon: _AlarmMetadata.Icon = _AlarmMetadata.timerDefaultMetadata.icon

    var body: some View {
        List {

            Section {
                TimerDurationPicker(hour: $hour, min: $min, sec: $sec)
            }
            .listRowBackground(Color.clear)
            
            Section {
                MetadataEntryView(title: $timerTitle, icon: $timerIcon)
            }
            .listSectionMargins(.top, 0)
            
            Section {
                Button(action: {
                    Task {
                        do {
                            let duration = TimeInterval.hms(self.hour, self.min, self.sec)
                            try await alarmManager.addTimer(
                                self.timerTitle,
                                icon: self.timerIcon,
                                duration: duration
                            )
                        } catch(let error) {
                            alarmManager.error = error
                        }
                    }
                }, label: {
                    Text("Start")
                        .foregroundStyle(.green)
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                })
                .disabled(self.hour == 0 && self.min == 0 && self.sec == 0)

            }
            .listSectionMargins(.top, 0)
            .listRowBackground(Color.green.opacity(0.3))

            
            Section {
                ForEach(alarmManager.runningTimer) { timer in
                    TimerCellView(
                        totalDuration: timer.timerDuration ?? 0,
                        alarmID: timer.id,
                        metadata: timer.metadata,
                        state: timer.state,
                        mode: timer.presentationMode
                    )

                }
                .onDelete(perform: { indexSet in
                    self.delete(indexSet, in: alarmManager.runningTimer)
                })
            }
            

            Section(alarmManager.recentTimer.isEmpty ? "" : "Recent") {
                ForEach(alarmManager.recentTimer) { timer in
                    
                    TimerCellView(
                        totalDuration: timer.timerDuration ?? 0,
                        alarmID: timer.id,
                        metadata: timer.metadata,
                        state: nil,
                        mode: nil
                    )

                }
                .onDelete(perform: { indexSet in
                    self.delete(indexSet, in: alarmManager.recentTimer)
                })

            }

        }
        .navigationTitle(ItsukiAlarmType.timer.title)
        .navigationBarTitleDisplayMode(.large)
        .toolbar(content: {
            ToolbarItem(placement: .topBarLeading, content: {
                EditButton()
                    .foregroundStyle(Color.alarmTint)
            })

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



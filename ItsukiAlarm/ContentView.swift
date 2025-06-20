//
//  ContentView.swift
//  ItsukiAlarm
//
//  Created by Itsuki on 2025/06/15.
//

import SwiftUI
import AlarmKit


struct ContentView: View {
    @State private var alarmManager: ItsukiAlarmManager = .shared
   
    @AppStorage("selectedTab") private var selectedTab: Int = 0
    
    var body: some View {
        let tabs = ItsukiAlarmType.allCases
        
        TabView(selection: $selectedTab, content: {
            ForEach(tabs, id:\.tabValue, content: { tab in
                Tab(tab.title, systemImage: tab.icon, value: tab.tabValue) {
                    NavigationStack {
                        Group {
                            switch tab {
                            case .alarm:
                                AlarmListView()
                            case .timer:
                                TimerListView()
                            case .custom:
                                CustomListView()
                            }
                        }
                        .environment(self.alarmManager)
                    }
                }
            })

        })
        .tabBarMinimizeBehavior(.never)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(.yellow.opacity(0.1))
        .onOpenURL { url in
            print("open open url: \(url)")
            let path = url.path(percentEncoded: false)
            if let alarmId = UUID(uuidString: path), let alarm = alarmManager.runningAlarms.first(where: {$0.id == alarmId}) {
                let type: ItsukiAlarmType = alarm.itsukiAlarmType
                self.selectedTab = type.tabValue
            }

        }
        .alert("Oops!", isPresented: $alarmManager.showError, actions: {
            Button(action: {
                alarmManager.showError = false
            }, label: {
                Text("OK")
            })
        }, message: {
            Text("\(alarmManager.error?.message ?? "Unknown Error")")
        })


    }
}

//
//  WeekdayPicker.swift
//  ItsukiAlarm
//
//  Created by Itsuki on 2025/06/20.
//


import SwiftUI

struct WeekdayPicker: View {
    @Binding var selectedWeekdays: Set<Locale.Weekday>
    
    @State private var showPopover: Bool = true
    @Environment(\.dismiss) private var dismiss

    private let weekdays = Locale.autoupdatingCurrent.orderedWeekdays
    
    var body: some View {
        Form {
            ForEach(self.weekdays, id: \.self) { weekday in
                Button(action: {
                    if selectedWeekdays.contains(weekday) {
                        selectedWeekdays.remove(weekday)
                    } else {
                        selectedWeekdays.insert(weekday)
                    }
                }) {
                    HStack {
                        Text("Every \(weekday.fullSymbol)")
                            .frame(maxWidth: .infinity, alignment: .leading)

                        if selectedWeekdays.contains(weekday) {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color.alarmTint)
                                .fontWeight(.semibold)
                        }
                    }
                    .contentShape(Rectangle())
                    
                }
            }
            
        }
        .buttonStyle(.plain)
        .navigationTitle("Repeat")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar(content: {
            ToolbarItem(placement: .topBarLeading, content: {
                Button(action: {
                    dismiss()
                }, label: {
                    HStack {
                        Image(systemName: "chevron.left")
                            .fontWeight(.semibold)
                        Text("Back")
                    }
                    .foregroundStyle(Color.alarmTint)
                    .padding(.horizontal, 4)
                })
            })
        })
        
    }
    
}

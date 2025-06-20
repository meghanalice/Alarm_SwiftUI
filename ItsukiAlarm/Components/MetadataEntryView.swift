//
//  MetadataEntryView.swift
//  ItsukiAlarm
//
//  Created by Itsuki on 2025/06/20.
//

import SwiftUI

struct MetadataEntryView: View {
    @Binding var title: String
    @Binding var icon: _AlarmMetadata.Icon
    
    var body: some View {
        HStack(spacing: 8) {
            Text("Label")
            
            TextField("Title", text: $title)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.trailing)
                .foregroundStyle(.gray)
        }
        
        HStack(spacing: 8) {
            Text("Icon")

            Picker(selection: $icon, content: {
                ForEach(_AlarmMetadata.Icon.allCases, id: \.self) { icon in
                    Label(icon.title, systemImage: icon.rawValue)
                        .tag(icon)
                }
            }, label: {
                Text("Alert")
            })
        }

    }
}

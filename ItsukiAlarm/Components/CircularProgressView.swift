//
//  CircularProgressView.swift
//  ItsukiAlarm
//
//  Created by Itsuki on 2025/06/20.
//

import Combine
import SwiftUI

// progressViewStyle(.circular) does not work for iOS main app
struct CircularProgressView: View {
    var color: Color
    @State var to: CGFloat
    var lineWidth: CGFloat
    
    var progressPerSec: CGFloat? = nil    
    @State private var cancellable: (any Cancellable)? = nil

    var body: some View {

        Circle()
            .trim(from: 0, to: self.to)
            .stroke(self.color, style: .init(lineWidth: self.lineWidth, lineCap: .round))
            .rotationEffect(.degrees(-90))
            .onAppear {
                if let progressPerSec {
                    self.cancellable = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
                        .sink(receiveValue: { _ in
                            self.to = to - progressPerSec
                        })
                }
            }

    }
}

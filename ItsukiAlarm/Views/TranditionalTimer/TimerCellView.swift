//
//  TimerCellView.swift
//  ItsukiAlarm
//
//  Created by Itsuki on 2025/06/20.
//

import SwiftUI
import AlarmKit

struct TimerCellView: View {
    @Environment(ItsukiAlarmManager.self) private var alarmManager
    
    var totalDuration: TimeInterval
    var alarmID: Alarm.ID
    var metadata: _AlarmMetadata
    var state: Alarm.State?
    var mode: AlarmPresentationState.Mode?
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                TimerDigitsView(totalDuration: self.totalDuration, presentationMode: self.mode)
                    .font(.system(size: 40, design: .rounded))
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 0) {
                    let title = metadata.title
                    let icon = metadata.icon
                    
                    Text("\(Image(systemName: icon.rawValue)) \(title.isEmpty ? _AlarmMetadata.timerDefaultMetadata.title : title)")
                        .padding(.leading, 8)

                    if let formattedString = totalDuration.formattedString {
                        Text(", \(formattedString)")
                    }
                    
                    Spacer()
                        .frame(width: 8)
                    
                    StateBadgeView(state: self.state)
                    
                }
                .font(.system(size: 16))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Group {
                switch self.mode {
                case .alert(_):
                    let stopButton = AlarmButton.stopButton
                    
                    Button(action: {
                        do {
                            try self.alarmManager.stopAlarm(alarmID)
                        } catch(let error) {
                            alarmManager.error = error
                        }
                    }, label: {
                        buttonImage(systemName: stopButton.systemImageName)
                            .foregroundStyle(stopButton.textColor)
                    })
                    .tint(.gray.opacity(0.3))

                case .countdown(let countdown):
                    let (elapsed, progressPerSec): (CGFloat, CGFloat?) = ((countdown.totalCountdownDuration - countdown.previouslyElapsedDuration) / countdown.totalCountdownDuration, 1.0 / countdown.totalCountdownDuration)
                   
                    
                    let pauseButton = AlarmButton.pauseButton
                    
                    Button(action: {
                        do {
                            try self.alarmManager.pauseAlarm(alarmID)
                        } catch(let error) {
                            alarmManager.error = error
                        }
                    }, label: {
                        buttonImage(systemName: pauseButton.systemImageName)
                            .foregroundStyle(pauseButton.textColor)
                    })
                    .tint(.clear)
                    .overlay(content: {
                        CircularProgressView(color: pauseButton.textColor, to: elapsed, lineWidth: 4, progressPerSec: progressPerSec)
                    })

                case .paused(let paused):
                    let elapsed: CGFloat = (paused.totalCountdownDuration - paused.previouslyElapsedDuration) / paused.totalCountdownDuration
                   

                    let resumeButton = AlarmButton.resumeButton

                    Button(action: {
                        do {
                            try self.alarmManager.resumeAlarm(alarmID)
                        } catch(let error) {
                            alarmManager.error = error
                        }
                    }, label: {
                        buttonImage(systemName: resumeButton.systemImageName)
                            .foregroundStyle(resumeButton.textColor)
                    })
                    .tint(.clear)
                    .overlay(content: {
                        CircularProgressView(color: resumeButton.textColor, to: elapsed, lineWidth: 4)
                    })
                    
                case nil:
                    Button(action: {
                        Task {
                            do {
                                try await alarmManager.addTimer(existing: self.alarmID)
                            } catch (let error) {
                                alarmManager.error = error
                            }
                        }
                    }, label: {
                        buttonImage(systemName: "play.fill")
                            .foregroundStyle(.green)
                    })
                    .tint(.green.opacity(0.3))
                    
                @unknown default:
                    EmptyView()
                }
            }
            .roundButtonStyle()
     
        }
    }
    
    func buttonImage(systemName: String) -> some View {
        Image(systemName: systemName)
             .font(.system(size: 24))
             .fontWeight(.bold)
             .frame(width: 24, height: 24)
             .padding(.all, 8)
    }
}

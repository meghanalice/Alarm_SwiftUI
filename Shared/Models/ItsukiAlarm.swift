//
//  ItsukiAlarm.swift
//  ItsukiAlarm
//
//  Created by Itsuki on 2025/06/17.
//

import SwiftUI
import AlarmKit

@dynamicMemberLookup
struct ItsukiAlarm: Codable, Identifiable, Sendable {
    var alarm: Alarm {
        didSet {
            self.updatePresentationState(oldAlarm: oldValue)
        }
    }
    
    var metadata: _AlarmMetadata
    
    // to make sure we can use the same logic in the main UI and live activity
    var presentationMode: AlarmPresentationState.Mode? = nil
    
    var id: UUID {
        alarm.id
    }
    
    init(alarm: Alarm, metadata: _AlarmMetadata, isRecent: Bool = false) {
        self.alarm = alarm
        self.metadata = metadata
        if !isRecent {
            self.updatePresentationState(oldAlarm: nil)
        }
    }
    
    subscript<T>(dynamicMember keyPath: KeyPath<_AlarmMetadata, T>) -> T {
        return metadata[keyPath: keyPath]
    }
    
    subscript<T>(dynamicMember keyPath: KeyPath<Alarm, T>) -> T {
        return alarm[keyPath: keyPath]
    }
    
    mutating private func updatePresentationState(oldAlarm: Alarm?) {

        var newMode: AlarmPresentationState.Mode? = self.presentationMode

        defer {
            self.presentationMode = newMode
        }
        
        let now = Date()
        
        guard let oldAlarm else {
            switch self.alarm.state {
                
            case .alerting:
                if let time = now.time {
                    newMode = .alert(.init(time: time))
                } else {
                    newMode = nil
                }
                return
                
            case .scheduled:
                guard let schedule = alarm.schedule else {
                    return
                }
                let time: Alarm.Schedule.Relative.Time = switch schedule {
                case .relative(let relative):
                    relative.time
                case .fixed(let date):
                    Alarm.Schedule.Relative.Time(hour: date.time?.hour ?? 0, minute: date.time?.minute ?? 0)
                @unknown default:
                    Alarm.Schedule.Relative.Time(hour: 0, minute: 0)
                }

                newMode = .alert(.init(time: time))
                return
                
            case .countdown:
                guard let duration = alarm.timerDuration else {
                    return
                }

                newMode = .countdown(.init(
                    totalCountdownDuration: duration,
                    previouslyElapsedDuration: 0, // The amount of time that elapsed before the most recent resumption of the countdown.
                    startDate: now, // The date at which the countdown was mostly recently resumed.
                    // The date the countdown starts.
                    fireDate: self.metadata.createdAt)
                )
                
                return
                
            case .paused:
                guard let duration = alarm.timerDuration else {
                    return
                }
                
                newMode = .paused(.init(totalCountdownDuration: duration, previouslyElapsedDuration: 0))
                return
            
                
            @unknown default:
                return
            }
                        
        }

        if oldAlarm.state == alarm.state && oldAlarm.id == alarm.id && oldAlarm.countdownDuration == alarm.countdownDuration && oldAlarm.schedule == alarm.schedule {
            return
        }

        
        switch (oldAlarm.state, alarm.state) {
        case (.scheduled, .countdown):
            guard let duration = alarm.timerDuration else {
                return
            }
            newMode = .countdown(.init(
                totalCountdownDuration: duration,
                previouslyElapsedDuration: 0, // The amount of time that elapsed before the most recent resumption of the countdown.
                startDate: now, // The date at which the countdown was mostly recently resumed.
                // The date the countdown starts.
                fireDate: self.metadata.createdAt)
            )
            return
        case (.countdown, .paused):
            guard case .countdown(let countdown) = self.presentationMode else {
                return
            }
            
            // The amount of time that elapsed before the most recent pause of the countdown.
            let previousElapsed = now.timeIntervalSince(countdown.startDate) + countdown.previouslyElapsedDuration
            newMode = .paused(.init(totalCountdownDuration: countdown.totalCountdownDuration, previouslyElapsedDuration: previousElapsed))
            
            return
            
        case (.paused, .countdown):
            guard case .paused(let pause) = self.presentationMode else {
                return
            }
            
            newMode = .countdown(.init(
                totalCountdownDuration: pause.totalCountdownDuration,
                previouslyElapsedDuration: pause.previouslyElapsedDuration, // The amount of time that elapsed before the most recent resumption of the countdown.
                startDate: now, // The date at which the countdown was mostly recently resumed.
                // The date the countdown starts.
                fireDate: self.metadata.createdAt)
            )
            
            return
            
        case (_, .scheduled):
            guard let schedule = alarm.schedule else {
                return
            }
            let time: Alarm.Schedule.Relative.Time = switch schedule {
            case .relative(let relative):
                relative.time
            case .fixed(let date):
                Alarm.Schedule.Relative.Time(hour: date.time?.hour ?? 0, minute: date.time?.minute ?? 0)
            default:
                Alarm.Schedule.Relative.Time(hour: 0, minute: 0)
            }

            newMode = .alert(.init(time: time))
            
            return
        case (_, .alerting):
            if let time = now.time {
                newMode = .alert(.init(time: time))
            } else {
                newMode = nil
            }
            return
            
        default:
            return
        }
        
    }
}

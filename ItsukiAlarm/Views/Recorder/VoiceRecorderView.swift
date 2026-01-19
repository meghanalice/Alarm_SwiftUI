import AVFoundation
import Combine
import SwiftUI

struct VoiceRecorderView: View {
    var alarmTitle: String
    @StateObject private var audioRecorder: AudioRecorder
    @Environment(\.dismiss) var dismiss

    init(alarmTitle: String) {
        self.alarmTitle = alarmTitle
        _audioRecorder = StateObject(wrappedValue: AudioRecorder(alarmTitle: alarmTitle))
    }

    var body: some View {
        NavigationView {
            VStack {
                if audioRecorder.recordings.isEmpty {
                    Text("No Recordings")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(audioRecorder.recordings) { recording in
                            VStack(alignment: .leading) {
                                Text(recording.alarmTitle)
                                    .font(.headline)
                                Text(recording.createdAt.formatted(date: .long, time: .shortened))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                Spacer()

                if audioRecorder.isRecording {
                    Text("Recording...")
                        .font(.title)
                        .foregroundStyle(.red)
                        .padding()
                } else {
                    Text("Tap to Record")
                        .font(.title)
                        .foregroundStyle(.secondary)
                        .padding()
                }

                Button(action: {
                    if audioRecorder.isRecording {
                        audioRecorder.stopRecording()
                    } else {
                        audioRecorder.startRecording()
                    }
                }) {
                    Image(
                        systemName: audioRecorder.isRecording
                            ? "stop.circle.fill" : "mic.circle.fill"
                    )
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .foregroundStyle(audioRecorder.isRecording ? .red : .blue)
                }
                .padding()
            }
            .navigationTitle("Voice Recorder")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Back") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                audioRecorder.fetchRecordings()
            }
        }
    }
}

struct Recording: Identifiable {
    let id = UUID()
    let fileURL: URL
    let createdAt: Date
    let alarmTitle: String
}

class AudioRecorder: NSObject, ObservableObject, AVAudioRecorderDelegate {

    var audioRecorder: AVAudioRecorder?
    @Published var isRecording = false
    @Published var recordings: [Recording] = []

    let alarmTitle: String

    init(alarmTitle: String) {
        self.alarmTitle = alarmTitle
        super.init()
        fetchRecordings()
    }

    func startRecording() {
        #if os(iOS)
            let recordingSession = AVAudioSession.sharedInstance()
            do {
                try recordingSession.setCategory(.playAndRecord, mode: .default)
                try recordingSession.setActive(true)
            } catch {
                print("Failed to set up recording session")
            }
        #endif

        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

        // Sanitize title for filename
        let sanitizedTitle = alarmTitle.components(separatedBy: .punctuationCharacters).joined(
            separator: "")
        let fileName = "\(sanitizedTitle)_\(Date().timeIntervalSince1970).m4a"
        let audioFilename = documentPath.appendingPathComponent(fileName)

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            isRecording = true
        } catch {
            print("Could not start recording: \(error)")
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        isRecording = false
        fetchRecordings()
    }

    func fetchRecordings() {
        recordings.removeAll()

        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]

        do {
            let directoryContents = try fileManager.contentsOfDirectory(
                at: documentDirectory, includingPropertiesForKeys: nil)
            for audio in directoryContents {
                if audio.pathExtension == "m4a" {
                    // Filename format: Title_Timestamp.m4a
                    let fileName = audio.lastPathComponent
                    let components = fileName.components(separatedBy: "_")

                    if components.count >= 2 {
                        let title = components[0]
                        let timestampString = components[1].replacingOccurrences(
                            of: ".m4a", with: "")
                        if let timestamp = TimeInterval(timestampString) {
                            let date = Date(timeIntervalSince1970: timestamp)
                            recordings.append(
                                Recording(fileURL: audio, createdAt: date, alarmTitle: title))
                        }
                    }
                }
            }

            recordings.sort(by: { $0.createdAt > $1.createdAt })

        } catch {
            print("Could not fetch recordings: \(error)")
        }
    }
}

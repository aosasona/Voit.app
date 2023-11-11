//
//  ExpandedRecordingView.swift
//  Voit
//
//  Created by Ayodeji Osasona on 19/10/2023.
//

import SwiftUI

struct ExpandedRecordingView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var manager: RecordingManager
    @AppStorage(AppStorageKey.skipForward.rawValue) var skipForward: Int = 5
    @AppStorage(AppStorageKey.skipBack.rawValue) var skipBack: Int = 5

    @Binding var recording: Recording
    @State private var showSpeedPicker = false
    public let dismiss: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(colors: [.accent.opacity(colorScheme == .dark ? 0.6 : 1), .black], startPoint: .topLeading, endPoint: .bottomTrailing))
                .ignoresSafeArea(.all)

            if recording.status == .processed {
                Player()
            } else {
                Text("Nothing here yet")
                    .foregroundStyle(.white)
            }
        }
        .background(.ultraThinMaterial)
        .onAppear {
            if manager.recording != recording {
                try? manager.play(recording: recording)
            }
        }
    }

    func Player() -> some View {
        VStack {
            Header()

            ScrollView {
                if let transcript = recording.transcript {
                    Text(transcript.asText())
                        .foregroundStyle(.white)
                        .font(.title2)
                        .lineLimit(nil)
                        .lineSpacing(3.0)
                        .multilineTextAlignment(.leading)
                }
            }
            .scrollIndicators(.hidden)
            .padding(.horizontal)

            Footer()
        }
    }

    func Header() -> some View {
        HStack {
            Button(action: dismiss) {
                Image(systemName: "chevron.down")
                    .font(.system(size: 20.0))
                    .foregroundColor(.white)
                    .padding(3.0)
            }
            .buttonStyle(PressableButtonStyle())

            Spacer()

            Text(recording.title)
                .font(.subheadline)
                .foregroundStyle(.white)
                .lineLimit(1)
                .padding(.horizontal, 12.0)

            Spacer()

            Menu {
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 20.0))
                    .foregroundColor(.white)
                    .padding(3.0)
            }
        }
        .padding(.horizontal, 20.0)
        .padding(.top, 8.0)
        .padding(.bottom, 14.0)
    }

    func Footer() -> some View {
        VStack(alignment: .center) {
            HStack(alignment: .center) {
                Menu {
                    ForEach([0.75, 1.0, 1.25, 1.5, 1.75, 2.0].reversed(), id: \.self) { speed in
                        Button(action: { manager.setPlaybackSpeed(speed: speed) }) {
                            Text(String(format: "%.2f", speed) + "x").tag(speed)
                        }
                    }
                } label: {
                    Button(action: {}) {
                        Text("\(manager.playbackSpeed.formatted())x")
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding()
                            .frame(minWidth: 75)
                    }
                    .buttonStyle(PressableButtonStyle())
                }

                Spacer()

                HStack(alignment: .center, spacing: 24.0) {
                    Button(action: { manager.goBackwards(Double(skipBack)) }) {
                        Image(systemName: "gobackward.\(skipBack)")
                            .font(.system(size: 28.0))
                            .foregroundColor(.white)
                    }
                    .buttonStyle(PressableButtonStyle())

                    Button(action: manager.isPlaying ? manager.pause : manager.resume) {
                        Image(systemName: manager.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 40.0))
                            .padding(30)
                            .foregroundColor(.black)
                    }
                    .frame(width: 70.0, height: 70.0)
                    .background(Color.white)
                    .clipShape(Circle())
                    .buttonStyle(PressableButtonStyle())

                    Button(action: { manager.goForwards(Double(skipForward)) }) {
                        Image(systemName: "goforward.\(skipForward)")
                            .font(.system(size: 28.0))
                            .foregroundColor(.white)
                    }
                    .buttonStyle(PressableButtonStyle())
                }

                Spacer()

                Button(action: {}) {
                    Image(systemName: "airplayaudio")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                .buttonStyle(PressableButtonStyle())
                .padding()
                .frame(minWidth: 75)
            }
        }
        .padding(.horizontal, 14.0)
        .padding(.vertical, 10.0)
    }
}

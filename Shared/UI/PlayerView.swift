//
//  PlayerView.swift
//  Forest
//
//  Created by Leptos on 5/15/21.
//  Copyright © 2021 Leptos. All rights reserved.
//

import SwiftUI
import AVKit

struct PlayerView {
    let url: URL
    let timeStamps: [TimeInterval] // assume sorted
    
    @Binding var timeStampIndex: Int?
    
    let showsPlaybackControls: Bool
    let videoGravity: AVLayerVideoGravity
    
    let shouldAutoPlay: Bool
    
    let playerItemEndCallback: (() -> Void)?
    
    // MARK: -
    
    init(url: URL, timeStamps: [TimeInterval], timeStampIndex: Binding<Int?>,
         showsPlaybackControls: Bool = true, videoGravity: AVLayerVideoGravity = .resizeAspect,
         shouldAutoPlay: Bool = false, playerItemEndCallback: (() -> Void)? = nil) {
        self.url = url
        self.timeStamps = timeStamps
        self._timeStampIndex = timeStampIndex
        self.showsPlaybackControls = showsPlaybackControls
        self.videoGravity = videoGravity
        self.shouldAutoPlay = shouldAutoPlay
        self.playerItemEndCallback = playerItemEndCallback
    }
    
    /// Common routine acting upon player object
    /// - Note: Should only be called from Representable `update` functions
    private func commonUpdatePlayer(_ player: AVPlayer, coordinator: Coordinator) {
        let currentAsset = player.currentItem?.asset as? AVURLAsset
        if currentAsset?.url != url {
            player.replaceCurrentItem(with: AVPlayerItem(url: url))
            if shouldAutoPlay {
                player.play()
            }
        }
        coordinator.updatePlayer(player, timeStamps: timeStamps)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(timeStampIndex: _timeStampIndex, playerItemEndCallback: playerItemEndCallback)
    }
    
    class Coordinator {
        @Binding var timeStampIndex: Int?
        let playerItemEndCallback: (() -> Void)?
        
        init(timeStampIndex: Binding<Int?>, playerItemEndCallback: (() -> Void)?) {
            self._timeStampIndex = timeStampIndex
            self.playerItemEndCallback = playerItemEndCallback
        }
        
        func updatePlayer(_ player: AVPlayer, timeStamps: [TimeInterval]) {
            if playerTimeObserver?.player != player || playerTimeObserver?.timeStamps != timeStamps {
                addPeriodicTimeObserver(for: timeStamps, to: player)
            }
            guard let playerItem = player.currentItem else {
                fatalError("player.currentItem must be valid at this point")
            }
            addEndTimeObserver(to: playerItem)
        }
        
        // MARK: - Periodic Time Observing
        
        private var playerTimeObserver: (player: AVPlayer, timeObserver: Any, timeStamps: [TimeInterval])? {
            didSet {
                guard let previous = oldValue else { return }
                previous.player.removeTimeObserver(previous.timeObserver)
            }
        }
        
        private func addPeriodicTimeObserver(for timeStamps: [TimeInterval], to player: AVPlayer) {
            guard !timeStamps.isEmpty else { return }
            
            let offsetStamps = timeStamps[1...] + [ .infinity ]
            let ranges = zip(timeStamps, offsetStamps).map { ($0)..<($1) }
            let observer = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1000), queue: nil) { [weak self] time in
                guard let self = self else { return }
                let currentSeconds = time.seconds
                self.timeStampIndex = ranges.firstIndex { $0.contains(currentSeconds) }
            }
            playerTimeObserver = (player, observer, timeStamps)
        }
        
        // MARK: - End Time Observing
        
        private let notificationCenter: NotificationCenter = .default
        private let notificationName: Notification.Name = .AVPlayerItemDidPlayToEndTime
        
        private var playerItemObserver: NSObjectProtocol? {
            didSet {
                guard let observer = oldValue else { return }
                notificationCenter.removeObserver(observer, name: notificationName, object: nil)
            }
        }
        
        private func addEndTimeObserver(to playerItem: AVPlayerItem) {
            playerItemObserver = notificationCenter.addObserver(forName: notificationName, object: playerItem, queue: .main) { [weak self] note in
                guard let self = self else { return }
                self.timeStampIndex = nil
                self.playerItemEndCallback?()
            }
        }
        // MARK: -
        deinit {
            playerTimeObserver = nil
            playerItemObserver = nil
        }
    }
}

#if canImport(AppKit)

extension PlayerView: NSViewRepresentable {
    func makeNSView(context: Context) -> AVPlayerView {
        let playerView = AVPlayerView()
        playerView.updatesNowPlayingInfoCenter = false
        playerView.allowsPictureInPicturePlayback = true
        
        playerView.player = AVPlayer()
        
        return playerView
    }
    
    func updateNSView(_ playerView: AVPlayerView, context: Context) {
        guard let player = playerView.player else {
            fatalError("playerView.player should always be set in makeNSView")
        }
        commonUpdatePlayer(player, coordinator: context.coordinator)
        
        playerView.controlsStyle = showsPlaybackControls ? .inline : .none
        playerView.showsFullScreenToggleButton = showsPlaybackControls
        playerView.videoGravity = videoGravity
    }
}

#elseif canImport(UIKit)

extension PlayerView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let playerController = AVPlayerViewController()
        playerController.updatesNowPlayingInfoCenter = false
        playerController.allowsPictureInPicturePlayback = true
        
        playerController.player = AVPlayer()
        
        return playerController
    }
    
    func updateUIViewController(_ playerController: AVPlayerViewController, context: Context) {
        guard let player = playerController.player else {
            fatalError("playerController.player should always be set in makeUIViewController")
        }
        commonUpdatePlayer(player, coordinator: context.coordinator)
        
        playerController.showsPlaybackControls = showsPlaybackControls
        playerController.videoGravity = videoGravity
    }
}

#else
#error("Unsupported UI framework")
#endif

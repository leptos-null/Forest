//
//  PlayerView.swift
//  Forest
//
//  Created by Leptos on 5/15/21.
//  Copyright © 2021 Leptos. All rights reserved.
//

import SwiftUI
import AVKit

final class PlayerView {
    let url: URL
    let timeStamps: [TimeInterval] // assume sorted
    
    @Binding var timeStampIndex: Int?
    
    let showsPlaybackControls: Bool
    let videoGravity: AVLayerVideoGravity
    
    private var playerTimeObserverPair: (player: AVPlayer, timeObserver: Any)? {
        didSet {
            guard let previous = oldValue else { return }
            previous.player.removeTimeObserver(previous.timeObserver)
        }
    }
    
    private func addPeriodicTimeObserver(to player: AVPlayer) {
        guard !timeStamps.isEmpty else { return }
        
        let offsetStamps = timeStamps[1...] + [ .infinity ]
        let ranges = zip(timeStamps, offsetStamps).map { $0 ..< $1 }
        let observer = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1000), queue: nil) { [weak self] time in
            guard let self = self else { return }
            let currentSeconds = time.seconds
            self.timeStampIndex = ranges.firstIndex { $0.contains(currentSeconds) }
        }
        playerTimeObserverPair = (player, observer)
    }
    
    init(url: URL, timeStamps: [TimeInterval], timeStampIndex: Binding<Int?>,
         showsPlaybackControls: Bool = true, videoGravity: AVLayerVideoGravity = .resizeAspect) {
        self.url = url
        self.timeStamps = timeStamps
        self._timeStampIndex = timeStampIndex
        self.showsPlaybackControls = showsPlaybackControls
        self.videoGravity = videoGravity
    }
    
    deinit {
        playerTimeObserverPair = nil
    }
}

#if canImport(AppKit)

extension PlayerView: NSViewRepresentable {
    func makeNSView(context: Context) -> AVPlayerView {
        let playerView = AVPlayerView()
        playerView.updatesNowPlayingInfoCenter = false
        playerView.allowsPictureInPicturePlayback = true
        return playerView
    }
    
    func updateNSView(_ playerView: AVPlayerView, context: Context) {
        let currentAsset = playerView.player?.currentItem?.asset as? AVURLAsset
        if currentAsset?.url != url {
            playerView.player = AVPlayer(url: url)
        }
        if let player = playerView.player, playerTimeObserverPair?.player != player {
            addPeriodicTimeObserver(to: player)
        }
        
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
        return playerController
    }
    
    func updateUIViewController(_ playerController: AVPlayerViewController, context: Context) {
        let currentAsset = playerController.player?.currentItem?.asset as? AVURLAsset
        if currentAsset?.url != url {
            playerController.player = AVPlayer(url: url)
        }
        if let player = playerController.player, playerTimeObserverPair?.player != player {
            addPeriodicTimeObserver(to: player)
        }
        
        playerController.showsPlaybackControls = showsPlaybackControls
        playerController.videoGravity = videoGravity
    }
}

#else
#error("Unsupported UI framework")
#endif

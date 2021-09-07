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
    
    var showsPlaybackControls: Bool = true
    var videoGravity: AVLayerVideoGravity = .resizeAspect
    
    var player: AVPlayer {
        let player = AVPlayer(url: url)
        
        if !timeStamps.isEmpty {
            let offsetStamps = timeStamps[1...] + [ .infinity ]
            let ranges = zip(timeStamps, offsetStamps).map { $0 ..< $1 }
            player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1000), queue: nil) { time in
                let currentSeconds = time.seconds
                timeStampIndex = ranges.firstIndex { $0.contains(currentSeconds) }
            }
        }
        return player
    }
}

#if canImport(AppKit)

extension PlayerView: NSViewRepresentable {
    func makeNSView(context: Context) -> AVPlayerView {
        let playerView = AVPlayerView()
        playerView.player = player
        playerView.controlsStyle = showsPlaybackControls ? .inline : .none
        playerView.videoGravity = videoGravity
        playerView.updatesNowPlayingInfoCenter = false
        playerView.showsFullScreenToggleButton = showsPlaybackControls
        playerView.allowsPictureInPicturePlayback = true
        return playerView
    }
    
    func updateNSView(_ nsView: AVPlayerView, context: Context) {
        
    }
}

#elseif canImport(UIKit)

extension PlayerView: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let playerController = AVPlayerViewController()
        playerController.player = player
        playerController.showsPlaybackControls = showsPlaybackControls
        playerController.videoGravity = videoGravity
        playerController.updatesNowPlayingInfoCenter = false
        playerController.allowsPictureInPicturePlayback = true
        return playerController
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        
    }
}

#else
#error("Unsupported UI framework")
#endif

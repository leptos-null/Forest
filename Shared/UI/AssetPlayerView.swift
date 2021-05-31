//
//  AssetPlayerView.swift
//  Forest
//
//  Created by Leptos on 5/15/21.
//  Copyright © 2021 Leptos. All rights reserved.
//

import SwiftUI

struct AssetPlayerView: View {
    let link: Entries.Asset.Link
    let pointsOfInterest: [Entries.Asset.LocalizedPointOfInterest]
    
    @State var pointOfInterestIndex: Int? = 0
    
    var timeStamps: [TimeInterval] {
        pointsOfInterest.map { $0.timeInterval }
    }
    
    var body: some View {
        DisclosureGroup {
            PlayerView(url: link.url, timeStamps: timeStamps, timeStampIndex: $pointOfInterestIndex)
                .aspectRatio(CGSize(width: 16, height: 9), contentMode: .fit)
            if let pointOfInterestIndex = pointOfInterestIndex, pointOfInterestIndex < pointsOfInterest.count {
                Text(pointsOfInterest[pointOfInterestIndex].value)
            }
        } label: {
            Link(link.name, destination: link.url)
        }
    }
}

extension Entries.Asset {
    struct Link: Identifiable {
        let name: String
        let url: URL
        
        var id: String {
            url.absoluteString
        }
    }
    
    var links: [Link] {
        [
            Link(name: "1080 H264", url: url_1080_H264),
            Link(name: "1080 HDR", url: url_1080_HDR),
            Link(name: "1080 SDR", url: url_1080_SDR),
            Link(name: "4K HDR", url: url_4K_HDR),
            Link(name: "4K SDR", url: url_4K_SDR),
        ]
    }
}

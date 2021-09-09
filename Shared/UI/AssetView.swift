//
//  AssetView.swift
//  Forest
//
//  Created by Leptos on 5/15/21.
//  Copyright © 2021 Leptos. All rights reserved.
//

import SwiftUI

struct AssetView: View {
    let asset: Entries.Asset
    let pointsOfInterest: [Entries.Asset.LocalizedPointOfInterest]
    
    @State var pointOfInterestIndex: Int? = 0
    @State var pickerSelection: Entries.Asset.Link
    
    var body: some View {
        ScrollView {
            PlayerView(url: pickerSelection.url, timeStamps: pointsOfInterest.map(\.timeInterval), timeStampIndex: $pointOfInterestIndex)
                .aspectRatio(CGSize(width: 16, height: 9), contentMode: .fit)
            
            HStack(spacing: 16) {
                Picker("Video", selection: $pickerSelection) {
                    ForEach(asset.links) { link in
                        Text(link.name)
                            .tag(link)
                    }
                }
                .labelsHidden() // on macOS, hides the picker title
                .pickerStyle(SegmentedPickerStyle())
                
                Link(destination: pickerSelection.url) {
                    Text(Image(systemName: "safari"))
                }
            }
            .padding(.horizontal, 16)
            
            PointsOfInterestTable(pointsOfInterest, activeIndex: pointOfInterestIndex)
                .padding(.top, 8)
                .animation(.easeInOut(duration: 0.45), value: pointOfInterestIndex)
        }
        .navigationTitle(asset.accessibilityLabel)
    }
}

extension Entries.Asset {
    struct Link: Identifiable, Hashable {
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

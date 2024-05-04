//
//  PointsOfInterestTable.swift
//  Forest
//
//  Created by Leptos on 9/9/21.
//  Copyright © 2021 Leptos. All rights reserved.
//

import SwiftUI

struct PointsOfInterestTable: View {
    let pointsOfInterest: [Entries.Asset.LocalizedPointOfInterest]
    let activeIndex: Int?
    
    private func stringFrom(seconds: TimeInterval) -> String {
        let secondsPerMinute: TimeInterval = 60
        let divided = seconds/secondsPerMinute
        let minutes = divided.rounded(.towardZero)
        let remainder = seconds - minutes * secondsPerMinute
        return String(format: "%.0f:%02.0f", minutes, remainder)
    }
    
    private func isPointOfInterestActive(_ pointOfInterest: Entries.Asset.LocalizedPointOfInterest) -> Bool {
        guard let pointOfInterestIndex = activeIndex else { return false }
        return pointOfInterest == pointsOfInterest[pointOfInterestIndex]
    }
    
    init(_ pointsOfInterest: [Entries.Asset.LocalizedPointOfInterest], activeIndex: Int? = nil) {
        self.pointsOfInterest = pointsOfInterest
        self.activeIndex = activeIndex
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Points of Interest")
                .font(.headline)
                .padding(.leading, 24)
                .padding(.bottom, 8)
            
            ForEach(pointsOfInterest) { pointOfInterest in
                HStack {
                    Text(pointOfInterest.value)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 4)
                    Text(stringFrom(seconds: pointOfInterest.timeInterval))
                        .font(.footnote)
                }
                .padding(8)
                .padding(.horizontal, 4)
                .background(
                    (isPointOfInterestActive(pointOfInterest) ? Color.accentColor.opacity(0.5) : Color.clear)
                        .cornerRadius(6)
                )
            }
            .font(.body)
            .padding(.horizontal, 16)
        }
    }
}

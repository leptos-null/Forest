//
//  Entries.swift
//  Forest
//
//  Created by Leptos on 5/15/21.
//  Copyright © 2021 Leptos. All rights reserved.
//

import Foundation

struct Entries: Codable {
    struct Asset: Codable, Hashable, Identifiable {
        enum CodingKeys: String, CodingKey {
            case id, accessibilityLabel, pointsOfInterest
            
            case url_1080_H264 = "url-1080-H264"
            case url_1080_HDR = "url-1080-HDR"
            case url_1080_SDR = "url-1080-SDR"
            case url_4K_HDR = "url-4K-HDR"
            case url_4K_SDR = "url-4K-SDR"
        }
        
        let id: UUID
        let accessibilityLabel: String
        let pointsOfInterest: [String: String]
        
        let url_1080_H264: URL
        let url_1080_HDR: URL
        let url_1080_SDR: URL
        let url_4K_HDR: URL
        let url_4K_SDR: URL
        
        struct LocalizedPointOfInterest: Codable, Hashable, Identifiable {
            let id: String
            let timestamp: String
            let value: String
            
            var timeInterval: TimeInterval {
                TimeInterval(timestamp) ?? .nan
            }
        }
        
        func decodePointsOfInterest(from bundle: Bundle) -> [LocalizedPointOfInterest] {
            pointsOfInterest.map { (timestamp, localizationKey) in
                let localizedString = bundle
                    .localizedString(forKey: localizationKey, value: nil, table: "Localizable.nocache")
                    .replacingOccurrences(of: "\n", with: " ") /* there are some random line breaks that don't seem meaningful */
                return LocalizedPointOfInterest(id: localizationKey, timestamp: timestamp, value: localizedString)
            }
        }
    }
    
    let assets: [Asset]
    let initialAssetCount: UInt
    let version: UInt
}

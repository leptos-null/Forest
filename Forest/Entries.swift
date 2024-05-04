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
            
            case categories, shotID
            
            case url_1080_H264 = "url-1080-H264"
            case url_1080_HDR = "url-1080-HDR"
            case url_1080_SDR = "url-1080-SDR"
            case url_4K_HDR = "url-4K-HDR"
            case url_4K_SDR = "url-4K-SDR"
        }
        
        let id: UUID
        let accessibilityLabel: String
        let pointsOfInterest: [String: String]
        
        let categories: [UUID]? // introduced in tvOS 15
        let shotID: String?     // introduced in tvOS 15
        
        let url_1080_H264: URL
        let url_1080_HDR: URL
        let url_1080_SDR: URL
        let url_4K_HDR: URL
        let url_4K_SDR: URL
        
        func decodeCategories(from entries: Entries) -> [Category]? {
            guard let entriesCategories = entries.categories,
                  let assetCategories = categories else { return nil }
            let categoryLookup = entriesCategories.identifiableLookup
            return assetCategories.compactMap { categoryLookup[$0] }
        }
    }
    
    struct Category: Codable, Hashable, Identifiable {
        let id: UUID
        let localizedDescriptionKey: String
        let localizedNameKey: String
        let preferredOrder: Int
        let previewImage: URL
        let representativeAssetID: UUID
        
        func localizedDescription(from bundle: Bundle) -> String {
            bundle.localizedString(forKey: localizedDescriptionKey, value: nil, table: "Localizable.nocache")
        }
        func localizedName(from bundle: Bundle) -> String {
            bundle.localizedString(forKey: localizedNameKey, value: nil, table: "Localizable.nocache")
        }
        func representativeAsset(in entries: Entries) -> Entries.Asset? {
            entries.assets.identifiableLookup[representativeAssetID]
        }
    }
    
    let assets: [Asset]
    let categories: [Category]? // introduced in tvOS 15
    let initialAssetCount: UInt
    let version: UInt
}

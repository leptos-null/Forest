//
//  Asset+LocalizedPointOfInterest.swift
//  Forest
//
//  Created by Leptos on 9/11/21.
//  Copyright © 2021 Leptos. All rights reserved.
//

import Foundation

extension Entries.Asset {
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

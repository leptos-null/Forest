//
//  Asset+VideoVariant.swift
//  Forest
//
//  Created by Leptos on 9/10/21.
//  Copyright © 2021 Leptos. All rights reserved.
//

import Foundation

extension Entries.Asset {
    enum VideoVariant: CaseIterable, Identifiable {
        case c_1080_H264
        case c_1080_HDR
        case c_1080_SDR
        case c_4K_HDR
        case c_4K_SDR
        
        var name: String {
            switch self {
            case .c_1080_H264: return "1080 H264"
            case .c_1080_HDR: return "1080 HDR"
            case .c_1080_SDR: return "1080 SDR"
            case .c_4K_HDR: return "4K HDR"
            case .c_4K_SDR: return "4K SDR"
            }
        }
        
        var id: Self { self }
    }
    
    func url(for videoVariant: VideoVariant) -> URL {
        switch videoVariant {
        case .c_1080_H264: return url_1080_H264
        case .c_1080_HDR: return url_1080_HDR
        case .c_1080_SDR: return url_1080_SDR
        case .c_4K_HDR: return url_4K_HDR
        case .c_4K_SDR: return url_4K_SDR
        }
    }
}

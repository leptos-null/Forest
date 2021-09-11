//
//  ShuffleSection.swift
//  Forest
//
//  Created by Leptos on 9/10/21.
//  Copyright © 2021 Leptos. All rights reserved.
//

import SwiftUI

struct ShuffleSection: View {
    struct Row<T: StringProtocol, S: StringProtocol>: View {
        let title: T
        let subtitle: S
        
        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                Label(title, systemImage: "shuffle")
                    .font(.body)
                Text(subtitle)
                    .font(.callout)
                    .padding(.leading, 8)
                    .lineLimit(nil)
            }
        }
    }
    
    let resources: Resources
    
    var body: some View {
        Section(header: SidebarSectionHeader("Shuffle")) {
            ShuffleNavigationLink(assets: resources.entries.assets, decodeBundle: resources.bundle) {
                Self.Row(title: "All", subtitle: "Shuffle all videos.")
            }
            
            if let categories = resources.entries.categories {
                ForEach(categories) { category in
                    ShuffleNavigationLink(assets: resources.entries.assets.filter { asset in
                        guard let assetCategories = asset.categories else { return false }
                        return assetCategories.contains(category.id)
                    }, decodeBundle: resources.bundle) {
                        Self.Row(
                            title: category.localizedName(from: resources.bundle),
                            subtitle: category.localizedDescription(from: resources.bundle)
                        )
                    }
                }
            }
        }
    }
}

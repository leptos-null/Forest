//
//  AssociatedAssetsView.swift
//  Forest
//
//  Created by Leptos on 5/15/21.
//  Copyright © 2021 Leptos. All rights reserved.
//

import SwiftUI

struct AssociatedAssetsView: View {
    let associatedAsset: Entries.AssociatedAssets
    let decodeBundle: Bundle
    
    var body: some View {
        Section(header: SidebarSectionHeader(associatedAsset.id)) {
            ForEach(associatedAsset.assets) { asset in
                AssetNavigationLink(asset: asset, decodeBundle: decodeBundle)
            }
        }
    }
}

extension Entries {
    struct AssociatedAssets: Identifiable {
        let id: String
        let assets: [Entries.Asset]
    }
    
    var associatedAssets: [AssociatedAssets] {
        Dictionary(grouping: assets, by: \.accessibilityLabel)
            .map { (key: String, value: [Entries.Asset]) in
                AssociatedAssets(id: key, assets: value)
            }
            .sorted { $0.id < $1.id }
    }
}

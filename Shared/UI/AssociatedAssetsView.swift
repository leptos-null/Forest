//
//  AssociatedAssetsView.swift
//  Forest
//
//  Created by Leptos on 5/15/21.
//  Copyright © 2021 Leptos. All rights reserved.
//

import SwiftUI

struct AssociatedAssetsView: View {
    let associatedAsset: Resources.AssociatedAssets
    let decodeBundle: Bundle
    
    var body: some View {
        Section(header: Text(associatedAsset.id).foregroundColor(.gray)) {
            ForEach(associatedAsset.assets) { asset in
                AssetNavigationLink(asset: asset, decodeBundle: decodeBundle)
            }
        }
        .font(.headline)
    }
}

extension Resources {
    struct AssociatedAssets: Identifiable {
        let id: String
        let assets: [Entries.Asset]
    }
    
    var associatedAssets: [AssociatedAssets] {
        entries.assets
            .reduce(into: [:]) { result, asset in
                let key = asset.accessibilityLabel
                
                var results = result[key] ?? []
                results.append(asset)
                result[key] = results
            }
            .map { (key: String, value: [Entries.Asset]) in
                AssociatedAssets(id: key, assets: value)
            }
            .sorted { $0.id < $1.id }
    }
}

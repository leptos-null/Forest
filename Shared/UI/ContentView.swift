//
//  ContentView.swift
//  Forest
//
//  Created by Leptos on 5/15/21.
//  Copyright © 2021 Leptos. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    let resourceDescriptor: Resources.Descriptor
    
    @State var resourceResult: Result<Resources, Error>
    @State var downloadDataTask: URLSessionDataTask?
    
    var resources: Resources? {
        switch resourceResult {
        case .success(let resources):
            return resources
        default:
            return nil
        }
    }
    var errorString: String? {
        switch resourceResult {
        case .failure(let error):
            return error.localizedDescription
        default:
            return nil
        }
    }
    
    var body: some View {
        if let resources = resources {
            NavigationView {
                List {
                    ShuffleSection(resources: resources)
                    
                    ForEach(resources.entries.associatedAssets) { associatedAsset in
                        AssociatedAssetsView(associatedAsset: associatedAsset, decodeBundle: resources.bundle)
                    }
                }
                .navigationTitle("Forest")
                .listStyle(SidebarListStyle())
            }
        } else if let downloadDataTask = downloadDataTask {
            ProgressView(downloadDataTask.progress)
                .padding(.horizontal, 24)
        } else {
            if let errorString = errorString {
                Text(errorString)
                    .font(.callout)
                    .padding(16)
                    .background(Color.red)
                    .cornerRadius(8)
                    .foregroundColor(.white)
                    .padding(24)
            }
            
            Button("Download Resources") {
                downloadDataTask = resourceDescriptor.downloadResources { result in
                    DispatchQueue.main.async {
                        resourceResult = result
                        downloadDataTask = nil
                    }
                }
            }
            .font(.headline)
            .padding(12)
            .contentShape(RoundedRectangle(cornerRadius: 8))
            .padding(12)
        }
    }
}

struct ContentViewPreviews: PreviewProvider {
    static var previews: some View {
        ContentView(
            resourceDescriptor: Resources.Descriptor(directory: URL(fileURLWithPath: "/dev/null")),
            resourceResult: .failure(POSIXError(.EBADF))
        )
    }
}

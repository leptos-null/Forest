//
//  ForestApp.swift
//  Forest
//
//  Created by Leptos on 5/15/21.
//  Copyright © 2021 Leptos. All rights reserved.
//

import SwiftUI

@main
struct ForestApp: App {
    let resourceDescriptor: Resources.Descriptor
    
    init() {
        let supportDirectories = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        guard let supportDirectory = supportDirectories.first else { fatalError("Could not locate resource directory") }
        let resourceURL = supportDirectory.appendingPathComponent("Forest/Resources")
        resourceDescriptor = Resources.Descriptor(directory: resourceURL)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(resourceDescriptor: resourceDescriptor, resourceResult: resourceDescriptor.resourceResult)
        }
    }
}

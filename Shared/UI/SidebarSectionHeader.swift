//
//  SidebarSectionHeader.swift
//  Forest
//
//  Created by Leptos on 9/11/21.
//  Copyright © 2021 Leptos. All rights reserved.
//

import SwiftUI

struct SidebarSectionHeader<T: StringProtocol>: View {
    let title: T
    
    init(_ title: T) {
        self.title = title
    }
    
    var body: some View {
        Text(title)
            .foregroundColor(.secondary)
            .font(.headline)
    }
}

struct SidebarSectionHeaderPreviews: PreviewProvider {
    static var previews: some View {
        Group {
            ForEach(ColorScheme.allCases, id: \.hashValue) { colorScheme in
                List {
                    Section(header: SidebarSectionHeader("Title")) {
                        Text("Content")
                    }
                }
                .listStyle(SidebarListStyle())
                .preferredColorScheme(colorScheme)
                .frame(width: 200, height: 80)
            }
        }
    }
}

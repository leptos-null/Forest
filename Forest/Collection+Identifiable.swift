//
//  Collection+Identifiable.swift
//  Forest
//
//  Created by Leptos on 9/9/21.
//  Copyright © 2021 Leptos. All rights reserved.
//

import Foundation

extension Collection where Element: Identifiable {
    var identifiableLookup: [Element.ID: Element] {
        reduce(into: [:]) { lookup, element in
            lookup[element.id] = element
        }
    }
}

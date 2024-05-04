//
//  Resources.swift
//  Forest
//
//  Created by Leptos on 5/15/21.
//  Copyright © 2021 Leptos. All rights reserved.
//

import Foundation

struct Resources {
    struct Descriptor {
        let directory: URL
        
        var remoteResourceLocation: URL {
            // thanks to https://github.com/JohnCoates/Aerial/blob/master/Documentation/OfflineMode.md
            guard let url = URL(string: "https://sylvan.apple.com/Aerials/resources-15.tar") else {
                fatalError("remoteResourceLocation must be able to be constructed")
            }
            return url
        }
        
        @discardableResult
        func downloadResources(completionHandler: @escaping (Result<Resources, Error>) -> Void) -> URLSessionDataTask {
            let task = URLSession.shared.dataTask(with: remoteResourceLocation) { [self] data, _, error in
                if let error = error {
                    completionHandler(.failure(error))
                    return
                }
                guard let data = data else { fatalError("data is required if there is no error") }
                do {
                    let tar = try Tar(data)
                    try tar.write(to: self.directory)
                    completionHandler(resourceResult)
                } catch {
                    completionHandler(.failure(error))
                }
            }
            task.resume()
            return task
        }
        
        var resourceResult: Result<Resources, Error> {
            Result {
                try Resources(url: directory)
            }
        }
    }
    
    let directory: URL
    
    let bundle: Bundle
    let entries: Entries
    
    init(url: URL) throws {
        directory = url
        
        guard let stringsBundle = Bundle(url: url.appendingPathComponent("TVIdleScreenStrings.bundle")) else {
            throw CocoaError(.fileReadUnknown)
        }
        bundle = stringsBundle
        
        let entryData = try Data(contentsOf: url.appendingPathComponent("entries.json"))
        let decoder = JSONDecoder()
        entries = try decoder.decode(Entries.self, from: entryData)
    }
}

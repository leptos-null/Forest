//
//  Tar.swift
//  Forest
//
//  Created by Leptos on 5/13/21.
//  Copyright © 2021 Leptos. All rights reserved.
//

import Foundation

struct Tar {
    enum ParsingError: Error {
        case stringDecodeFailed
        case integerDecodeFailed
        case unknown(typeflag: UInt8)
        case unexpectedEndOfFile
    }
    
    // https://www.gnu.org/software/tar/manual/html_node/Standard.html
    struct Entry {
        enum TypeFlag {
            case regular
            case link(to: String)
            case symbolicLink(to: String)
            case character(major: UInt, minor: UInt)
            case block(major: UInt, minor: UInt)
            case directory
            case fifo
            case contiguous
            
            var attributeType: FileAttributeType {
                switch self {
                case .regular: return .typeRegular
                case .link: return .typeRegular
                case .symbolicLink: return .typeSymbolicLink
                case .character: return .typeCharacterSpecial
                case .block: return .typeBlockSpecial
                case .directory: return .typeDirectory
                case .fifo: return .typeUnknown
                case .contiguous: return .typeRegular
                }
            }
        }
        
        let name: String
        let mode: mode_t
        let uid: uid_t
        let gid: gid_t
        let modificationDate: Date
        let chksum: UInt
        let typeFlag: TypeFlag
        let magic: String
        let version: String
        let uname: String
        let gname: String
        
        let data: Data
        
        
        private static func string<S>(from bytes: S) throws -> String where S: Sequence, S.Element == UInt8 {
            guard let string = String(bytes: bytes, encoding: .ascii) else {
                throw ParsingError.stringDecodeFailed
            }
            let validPrefix = string.prefix { $0 != .null }
            return String(validPrefix)
        }
        private static func int<S, R>(from bytes: S) throws -> R where S: Sequence, S.Element == UInt8, R: FixedWidthInteger {
            let string = try string(from: bytes)
            let numerals = string.trimmingCharacters(in: .whitespaces)
            guard let integer = R(numerals, radix: 8) else {
                throw ParsingError.integerDecodeFailed
            }
            return integer
        }
        
        fileprivate init<ByteCollection>(_ bufferPointer: ByteCollection) throws where ByteCollection: Collection,
                                                                                       ByteCollection.Element == UInt8,
                                                                                       ByteCollection.Index: BinaryInteger {
            let fullHeaderSize: ByteCollection.Index = 512
            let relativeIndex = bufferPointer.startIndex
            
            name = try Self.string(from: bufferPointer[relativeIndex+0..<relativeIndex+100])
            mode = try Self.int(from: bufferPointer[relativeIndex+100..<relativeIndex+108])
            uid = try Self.int(from: bufferPointer[relativeIndex+108..<relativeIndex+116])
            gid = try Self.int(from: bufferPointer[relativeIndex+116..<relativeIndex+124])
            let size: Int = try Self.int(from: bufferPointer[relativeIndex+124..<relativeIndex+136])
            let mtime: Int = try Self.int(from: bufferPointer[relativeIndex+136..<relativeIndex+148])
            chksum = try Self.int(from: bufferPointer[relativeIndex+148..<relativeIndex+156])
            let typeflag = bufferPointer[relativeIndex+156]
            let linkname = try Self.string(from: bufferPointer[relativeIndex+157..<relativeIndex+257])
            magic = try Self.string(from: bufferPointer[relativeIndex+257..<relativeIndex+263])
            version = try Self.string(from: bufferPointer[relativeIndex+263..<relativeIndex+265])
            uname = try Self.string(from: bufferPointer[relativeIndex+265..<relativeIndex+297])
            gname = try Self.string(from: bufferPointer[relativeIndex+297..<relativeIndex+329])
            let devmajor: UInt = try Self.int(from: bufferPointer[relativeIndex+329..<relativeIndex+337])
            let devminor: UInt = try Self.int(from: bufferPointer[relativeIndex+337..<relativeIndex+345])
            
            
            modificationDate = Date(timeIntervalSince1970: TimeInterval(mtime))
            
            switch typeflag {
            case 48, 0:
                typeFlag = .regular
            case 49:
                typeFlag = .link(to: linkname)
            case 50:
                typeFlag = .symbolicLink(to: linkname)
            case 51:
                typeFlag = .character(major: devmajor, minor: devminor)
            case 52:
                typeFlag = .block(major: devmajor, minor: devminor)
            case 53:
                typeFlag = .directory
            case 54:
                typeFlag = .fifo
            case 55:
                typeFlag = .contiguous
            default:
                throw ParsingError.unknown(typeflag: typeflag)
            }
            
            let dataStartIndex = relativeIndex + fullHeaderSize
            let dataEndIndex = dataStartIndex + ByteCollection.Index(size)
            guard dataEndIndex < bufferPointer.endIndex else {
                throw ParsingError.unexpectedEndOfFile
            }
            data = Data(bufferPointer[dataStartIndex..<dataEndIndex])
        }
        
        var attributes: [FileAttributeKey: Any] {
            var attributes: [FileAttributeKey: Any] = [
                .type: typeFlag.attributeType,
                .size: data.count,
                .modificationDate: modificationDate,
                .ownerAccountName: uname,
                .groupOwnerAccountName: gname,
                .posixPermissions: mode,
                .ownerAccountID: uid,
                .groupOwnerAccountID: gid
            ]
            switch typeFlag {
            case .character(major: let major, minor: let minor),
                 .block(major: let major, minor: let minor):
                let dev = (major << 24) | minor
                attributes[.deviceIdentifier] = dev
            default:
                break
            }
            return attributes
        }
        
        func write(to workingDirectory: URL) throws {
            let writeLocation = workingDirectory.appendingPathComponent(name)
            let fileManager: FileManager = .default
            switch typeFlag {
            case .regular, .character, .block, .contiguous:
                fileManager.createFile(atPath: writeLocation.path, contents: data, attributes: attributes)
            case .link(let path):
                guard let destinationURL = URL(string: path, relativeTo: writeLocation) else {
                    throw URLError(.badURL)
                }
                try fileManager.linkItem(at: destinationURL, to: writeLocation)
            case .symbolicLink(let path):
                guard let destinationURL = URL(string: path, relativeTo: writeLocation) else {
                    throw URLError(.badURL)
                }
                try fileManager.createSymbolicLink(at: writeLocation, withDestinationURL: destinationURL)
            case .directory:
                try fileManager.createDirectory(at: writeLocation, withIntermediateDirectories: false, attributes: attributes)
            case .fifo:
                let mkfifoResult = writeLocation.withUnsafeFileSystemRepresentation { fileName in
                    mkfifo(fileName, mode)
                }
                guard mkfifoResult == 0 else {
                    guard let errorCode = POSIXError.Code(rawValue: errno) else {
                        fatalError("errno (\(errno)) could not be translated to POSIXError.Code")
                    }
                    throw POSIXError(errorCode)
                }
                try fileManager.setAttributes(attributes, ofItemAtPath: writeLocation.path)
            }
        }
    }
    
    
    let entries: [Entry]
    
    init(_ data: Data) throws {
        var entries: [Entry] = []
        
        try data.withUnsafeBytes { (bufferRawPointer: UnsafeRawBufferPointer) in
            let bufferPointer: UnsafeBufferPointer = bufferRawPointer.bindMemory(to: UInt8.self)
            let bufferLength: Int = bufferPointer.count
            
            var readBase: Int = 0
            while readBase < bufferLength {
                let blockSize = 512
                let readBaseBlockMod = readBase % blockSize
                if readBaseBlockMod != 0 {
                    readBase += blockSize - readBaseBlockMod
                }
                
                guard (readBase + blockSize) < bufferLength else {
                    // make sure reading this block won't go out of bounds
                    // not an error, this may be the end of the archive
                    break
                }
                
                let isNullBlock = bufferPointer[readBase..<readBase+blockSize].allSatisfy { $0 == 0 }
                if isNullBlock {
                    break // typical way to know if the entries are done
                }
                let entry = try Entry(bufferPointer.dropFirst(readBase))
                entries.append(entry)
                
                readBase += blockSize + entry.data.count
            }
        }
        self.entries = entries
    }
    
    func write(to url: URL) throws {
        let fileManager: FileManager = .default
        if fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }
        try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        
        try entries.forEach { try $0.write(to: url) }
    }
}

private extension Character {
    static let null = Character(unicodeScalarLiteral: "\0")
}

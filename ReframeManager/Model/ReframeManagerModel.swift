//
//  ReframeManagerModel.swift
//  ReframeManager
//
//  Created by Janne Tuukkanen on 7.11.2020.
//  Copyright © 2020 Ibfekna. All rights reserved.
//

import Foundation
import Combine




let FileExtensions = [
    "highDef" : "360",
    "lowDef" : "LRV",
    "preview" : "THM",
    "reframe" : "reframe"
]

struct FileItem: Equatable, Hashable {
    var name: String
    var url: URL
    var size: Int
    var creationDate: Date
    var modificationDate: Date
    var type: String
    
    // Beginning of the file name, before first dot
    var videoName: String {
        let a = name.components(separatedBy: ".")
        return a[0]
    }
    
    // End of the file name, after the last dot
    var fileExtension: String {
        let a = name.components(separatedBy: ".")
        if a.count == 0 { return "" }
        return a[a.count - 1]
    }
    
    var isKnownType: Bool {
        return FileExtensions.values.contains(fileExtension)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(size)
    }
}

struct Video360File {
    var fileItem: FileItem
    
    var creationTimeStamp: String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd-HH-mm-ss-000ZZZ"
        return df.string(from: fileItem.creationDate)
    }
    
    // This reframe file name is used by the Player app
    var reframeEditFileName: String {
        let ext = FileExtensions["reframe"] ?? ""
        return "\(creationTimeStamp)-\(fileItem.size).\(ext)"
    }
}

struct ReframeFile: Hashable  {
    var fileItem: FileItem
    
    // Part of the file name between the first and last dots
    var reframeName: String {
        let a = fileItem.name.components(separatedBy: ".")
        var s = ""
        for i in 1..<a.count - 1 {
            if i > 1 { s += "." }
            s += a[i]
        }
        
        return s
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(fileItem)
    }
}

struct Video360: Hashable {
    var name: String
    
    var previewImageFile: FileItem?
    
    var highDef360File: Video360File?
    var lowDef360File: Video360File?
    
    var reframeFiles = [ReframeFile]()
    var otherFiles = [FileItem]()       // normally this should remain empty
    
    mutating func addFile(fileItem: FileItem) {
        switch fileItem.fileExtension {
            case FileExtensions["highDef"]:
                highDef360File = Video360File(fileItem: fileItem)
            case FileExtensions["lowDef"]:
                lowDef360File = Video360File(fileItem: fileItem)
            case FileExtensions["preview"]:
                previewImageFile = fileItem
            case FileExtensions["reframe"]:
                print("Add reframe: \(fileItem.name)")
                reframeFiles.append(ReframeFile(fileItem: fileItem))
        default:
            otherFiles.append(fileItem)
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
   
    static func == (lhs: Video360, rhs: Video360) -> Bool {
        return lhs.name == rhs.name
    }
}

class Directory: ObservableObject {
    static let DEFAULT_WORKDIR = "~/Documents/tmp/360Video"
    static let DEFAULT_PLAYERDIR = "~/Library/Containers/com.gopro.GoPro-Player/Data/Library/Application Support/"
    
    @Published var url: URL? { didSet { loadDirectory() }}
    @Published var playerDirURL: URL?
    @Published var videos = [Video360]()
    
    var readable: Bool = false // Can directory be read?

    init(path: String, playerDirPath: String) {
        self.url = URL(fileURLWithPath: NSString(string: path).expandingTildeInPath)
        self.playerDirURL = URL(fileURLWithPath: NSString(string: playerDirPath).expandingTildeInPath)
    }
    
    init() {}
    
    func loadDirectory() {
        readable = true
        let fileItems = loadDir()
        
        for fileItem in fileItems {
            if videoIndexByName(name: fileItem.videoName) == nil {
                videos.append(Video360(name: fileItem.videoName))
            }
            
            let i = videoIndexByName(name: fileItem.videoName)
            videos[i!].addFile(fileItem: fileItem)
        }
    }
    
    private func videoIndexByName(name: String) -> Int? {
        for (index, video) in videos.enumerated() {
            if video.name == name {
                return index
            }
        }
        return nil
    }
    
    // If error is encountered reading directory contents
    // the value of readable member variable is se to false
    private func loadDir() -> [FileItem] {
        guard url != nil else {
            return [FileItem]()
        }
        
        var fileItems = [FileItem]()
        let fileManager = FileManager.default
        
        do {
            let files = try fileManager.contentsOfDirectory(atPath: url!.path)
            
            for file in files {
                let fileItem = try getFileInfo(file: file, fileManager: fileManager)
                
                if fileItem.isKnownType {
                    print("Known extension: Append")
                    fileItems.append(fileItem)
                }
            }
        } catch {
            readable = false
        }
        
        return fileItems
    }
    
    private func getFileInfo(file: String, fileManager: FileManager) throws -> FileItem {
        var fileURL = self.url!
        fileURL.appendPathComponent(file)
        
        let attributes = try fileManager.attributesOfItem(atPath: fileURL.path)
        
        let modificationDate = attributes[FileAttributeKey.modificationDate] as? Date ?? Date(timeIntervalSince1970: 0)
        let creationDate = attributes[FileAttributeKey.creationDate] as? Date ?? Date(timeIntervalSince1970: 0)
        let size = attributes[FileAttributeKey.size] as? Int ?? 0
        let type = attributes[FileAttributeKey.type] as? String ?? "unknown"
    
        return FileItem(
            name: file,
            url: fileURL,
            size: size,
            creationDate: creationDate,
            modificationDate: modificationDate,
            type: type
        )
    }
}

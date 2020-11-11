//
//  ReframeManagerModel.swift
//  ReframeManager
//
//  Created by Janne Tuukkanen on 7.11.2020.
//  Copyright © 2020 Ibfekna. All rights reserved.
//

import Foundation
import Combine


let WORKDIR = "~/Documents/"
let PLAYERDIR = "~/Library/Containers/com.gopro.GoPro-Player/Data/Library/Application Support/"

struct FileExtensions {
    static let highDef = "360"
    static let lowDef = "LRV"
    static let reframe = "reframe"
}

struct FileItem {
    var name: String
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
        "\(creationTimeStamp)-\(fileItem.size).\(FileExtensions.reframe)"
    }
}

struct ReframeFile  {
    var fileItem: FileItem
    
    // Part of the file name between the first and last dots
    var reframeName: String {
        let a = fileItem.name.components(separatedBy: ".")
        var s = ""
        for i in 1..<a.count {
            if i > 1 { s += "." }
            s += a[i]
        }
        
        return s
    }
}

struct Video360 {
    var name: String
    
    var previewImage: FileItem?
    var highDef360File: Video360File?
    var lowDef360File: Video360File?
    
    var reframeFiles = [ReframeFile]()
    var otherFiles = [FileItem]()       // normally this should remain empty
    
    mutating func addFile(fileItem: FileItem) {
        switch fileItem.fileExtension {
            case FileExtensions.highDef:
                highDef360File = Video360File(fileItem: fileItem)
            case FileExtensions.lowDef:
                lowDef360File = Video360File(fileItem: fileItem)
            case FileExtensions.reframe:
                reframeFiles.append(ReframeFile(fileItem: fileItem))
        default:
            otherFiles.append(fileItem)
        }
    }
}

class Directory: ObservableObject {
    @Published var url: URL
    @Published var playerDirURL: URL
    @Published var videos = [String : Video360]()
    
    var readable: Bool = true // if there are issues reading directory listing, this is set to false

    init(path: String, playerDirPath: String) {
        print("Init path: \(path)")
        print("Init payerdir: \(playerDirPath)")
        self.url = URL(fileURLWithPath: NSString(string: path).expandingTildeInPath)
        self.playerDirURL = URL(fileURLWithPath: NSString(string: playerDirPath).expandingTildeInPath)
        print("URL path: \(self.url)")
        print("Init payerdir: \(self.playerDirURL)")
    }
 
    convenience init(path: String) {
        self.init(path: path, playerDirPath: PLAYERDIR)
    }
    
    convenience init() {
        self.init(path: WORKDIR, playerDirPath: PLAYERDIR)
    }
    
    func loadDirectory() {
        let fileItems = loadDir()
        
        for fileItem in fileItems {
            if videos[fileItem.videoName] == nil {
                videos[fileItem.videoName] = Video360(name: fileItem.videoName)
            }
            
            videos[fileItem.videoName]?.addFile(fileItem: fileItem)
        }
    }
    // If error is encountered reading directory contents
    // the value of readable member variable is se to false
    private func loadDir() -> [FileItem] {
        var fileItems = [FileItem]()
        let fileManager = FileManager.default
        
        do {
            let files = try fileManager.contentsOfDirectory(atPath: url.path)
            
            for file in files {
                let fileItem = try getFileInfo(file: file, fileManager: fileManager)
                
                fileItems.append(fileItem)
            }
        } catch {
            readable = false
        }
        
        return fileItems
    }
    
    private func getFileInfo(file: String, fileManager: FileManager) throws -> FileItem {
        var fileURL = self.url
        fileURL.appendPathComponent(file)
        
        let attributes = try fileManager.attributesOfItem(atPath: fileURL.path)
        
        let modificationDate = attributes[FileAttributeKey.modificationDate] as? Date ?? Date(timeIntervalSince1970: 0)
        let creationDate = attributes[FileAttributeKey.creationDate] as? Date ?? Date(timeIntervalSince1970: 0)
        let size = attributes[FileAttributeKey.size] as? Int ?? 0
        let type = attributes[FileAttributeKey.type] as? String ?? "unknown"
    
        return FileItem(
            name: file,
            size: size,
            creationDate: creationDate,
            modificationDate: modificationDate,
            type: type
        )
    }
}

//
//  ReframeManagerModel.swift
//  ReframeManager
//
//  Created by Janne Tuukkanen on 7.11.2020.
//  Copyright © 2020 Ibfekna. All rights reserved.
//

import Foundation
import Combine

enum ReframeManagerError: Error {
    case UnspecifiedError
    case FileAlreadyExists
    case DirectoryNotFound
    case InvalidName
    case CannotDelete
    case CannotCreate
    case EditorLaunchFailure
}

let FileExtensions = [
    "highDef" : "360",
    "lowDef" : "LRV",
    "preview" : "THM",
    "reframe" : "reframe",
    "backup" : "BACKUP"
]

func validName(name: String) -> Bool {
    if name.count == 0 || name.count > 50 {
        return false
    }
    
    if name.contains("/") || name.contains("\\") {
        return false
    }

    if name.contains(".") || name.contains("@") {
        return false
    }
    
    if name.contains("\"") || name.contains("\'") {
        return false
    }
    
    if name.contains("~") || name.contains("|") {
        return false
    }
    
    if name.contains("$") || name.contains("%") {
        return false
    }
    
    if name.contains("*") || name.contains("?") {
        return false
    }
    
    return true
}

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

    /*
    static let REFRAME_TEMPLATE: [UInt8] = [
            0x35, 0x0a, 0x14, 0x0a, 0x2d, 0x0d, 0x6b, 0xa6, 0x15, 0xbc, 0x08, 0xa9, 0x3d, 0x90, 0x8b, 0x1d,
            0x57, 0xa6, 0x25, 0x3a, 0x56, 0xe8, 0x3f, 0x7f, 0x00, 0x15, 0x00, 0x00, 0x18, 0x00, 0x20, 0x04,
            0x28, 0x00, 0x30, 0x01, 0x38, 0x00, 0x40, 0x00, 0x48, 0x00, 0x50, 0x00, 0x5d, 0x00, 0x00, 0x00,
            0x43, 0x34, 0x00, 0x65, 0x0e, 0xc0, 0x18, 0x43, 0x20, 0x00, 0xd8, 0x80, 0x07, 0xa1, 0x80, 0x28,
            0xa1, 0xd8, 0x30, 0x07, 0x38, 0x10, 0x40, 0x09, 0x00, 0x04
    ]

    static let REFRAME_TEMPLATE: [UInt16] = [
        0x350a, 0x140a, 0x2d0d, 0x6ba6, 0x15bc, 0x08a9, 0x3d90, 0x8b1d,
        0x57a6, 0x253a, 0x56e8, 0x3f7f, 0x0015, 0x0000, 0x1800, 0x2004,
        0x2800, 0x3001, 0x3800, 0x4000, 0x4800, 0x5000, 0x5d00, 0x0000,
        0x4334, 0x0065, 0x0ec0, 0x1843, 0x2000, 0xd880, 0x07a1, 0x8028,
        0xa1d8, 0x3007, 0x3810, 0x4009, 0x0004
    ]
*/
    static let REFRAME_TEMPLATE: [UInt16] = [
        0x350a, 0x140a, 0x2d0d, 0x6ba6, 0x15bc, 0x08a9, 0x3d90, 0x8b1d,
        0x57a6, 0x253a, 0x56e8, 0x3f7f, 0x0015, 0x0000, 0x1800, 0x2004,
        0x2800, 0x3001, 0x3800, 0x4000, 0x4800, 0x5000, 0x5d00, 0x0000,
        0x4334, 0x0065, 0x0ec0, 0x1843, 0x2000, 0xd880, 0x07a1, 0x8028,
        0xa1d8, 0x3007, 0x3810, 0x4009, 0x0004 ]
    
    static var reframeData: Data {
        let pointer = UnsafeBufferPointer(
            start: ReframeFile.REFRAME_TEMPLATE,
            count: ReframeFile.REFRAME_TEMPLATE.count)
        
        return Data(buffer: pointer)
    }
    
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

class Video360: Hashable, ObservableObject {
    var name: String
    var previewImageFile: FileItem?
    
    var highDef360File: Video360File?
    var lowDef360File: Video360File?
    
    @Published var reframeFiles = [ReframeFile]()
    var otherFiles = [FileItem]()       // normally this should remain empty
    
    init(name: String) {
        self.name = name
    }
    
    func addFile(fileItem: FileItem) {
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
    
    func reframeExists(name: String) -> Bool {
        return reframeIndexByName(name: name) != nil
    }
    
    func reframeIndexByName(name: String) -> Int? {
        for (index, reframeFile) in reframeFiles.enumerated() {
            if reframeFile.reframeName == name {
                return index
            }
        }
        return nil
    }
    
    func newReframe(reframeName: String, directory: Directory) throws {
        guard var fileURL = directory.url else {
            throw ReframeManagerError.DirectoryNotFound
        }
        
        guard validName(name: reframeName) else {
            throw ReframeManagerError.InvalidName
        }
        
        let fileManager = FileManager.default
        let ext = FileExtensions["reframe"]!
        let fileName = "\(self.name).\(reframeName).\(ext)"
        fileURL.appendPathComponent(fileName)
        
        if(fileManager.fileExists(atPath: fileURL.path)) {
            throw ReframeManagerError.FileAlreadyExists
        }
   
        try ReframeFile.reframeData.write(to: fileURL)
        
        let fileItem = try directory.getFileInfo(file: fileName, fileManager: fileManager)
        directory.addFile(fileItem)
    }
    
    func deleteReframe(reframeFile: ReframeFile) throws {
        
        let fileManager = FileManager.default
        try fileManager.removeItem(at: reframeFile.fileItem.url)
        
        if let index = reframeFiles.firstIndex(of: reframeFile) {
            reframeFiles.remove(at: index)
        }
    }
    
    func copyReframe(reframeFile: ReframeFile, newName: String, directory: Directory) throws {
        guard var fileURL = directory.url else {
            throw ReframeManagerError.DirectoryNotFound
        }
        
        guard validName(name: newName) else {
            throw ReframeManagerError.InvalidName
        }
        
        
        let fileManager = FileManager.default
        let ext = FileExtensions["reframe"]!
        let fileName = "\(self.name).\(newName).\(ext)"
        fileURL.appendPathComponent(fileName)
        
        if(fileManager.fileExists(atPath: fileURL.path)) {
            throw ReframeManagerError.FileAlreadyExists
        }
        
        try fileManager.copyItem(at: reframeFile.fileItem.url, to: fileURL)
        
        let fileItem = try directory.getFileInfo(file: fileName, fileManager: fileManager)
        directory.addFile(fileItem)
    }
}


class Directory: ObservableObject {
    static let DEFAULT_WORKDIR = "~/Documents/tmp/360Video"
    static let DEFAULT_PLAYERDIR = "~/Library/Containers/com.gopro.GoPro-Player/Data/Library/Application Support/"
    
    @Published var url: URL? { didSet { loadDirectory() }}
    @Published var playerDirURL: URL?
    @Published var videos = [Video360]()
    
    var path: String { url?.path ?? "" }
    
    init(path: String, playerDirPath: String) {
        self.url = URL(fileURLWithPath: NSString(string: path).expandingTildeInPath)
        self.playerDirURL = URL(fileURLWithPath: NSString(string: playerDirPath).expandingTildeInPath)
    }
    
    init() {}
    
    func loadDirectory() {
        videos = [Video360]()
        var fileItems: [FileItem]
        
        do {
            fileItems = try loadDir()
        } catch {
            print("Problem loading directory")
            return
        }
        
        for fileItem in fileItems {
            addFile(fileItem)
        }
    }
    
    func addFile(_ fileItem: FileItem) {
        if videoIndexByName(name: fileItem.videoName) == nil {
            videos.append(Video360(name: fileItem.videoName))
        }
        
        let i = videoIndexByName(name: fileItem.videoName)
        videos[i!].addFile(fileItem: fileItem)
    }
    
    private func videoIndexByName(name: String) -> Int? {
        for (index, video) in videos.enumerated() {
            if video.name == name {
                return index
            }
        }
        return nil
    }
    
    private func loadDir() throws -> [FileItem] {
        guard url != nil else {
            return [FileItem]()
        }
        
        var fileItems = [FileItem]()
        let fileManager = FileManager.default
        
        let files = try fileManager.contentsOfDirectory(atPath: url!.path)
            
        for file in files {
            let fileItem = try getFileInfo(file: file, fileManager: fileManager)
                
            if fileItem.isKnownType {
                fileItems.append(fileItem)
            }
        }
        
        return fileItems
    }
    
    func getFileInfo(file: String, fileManager: FileManager) throws -> FileItem {
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
    
    func renameVideo(oldName: String, newName: String) throws {
        guard url != nil else {
            throw ReframeManagerError.DirectoryNotFound
        }
        
        guard validName(name: newName) else {
            throw ReframeManagerError.InvalidName
        }
        
        for video in videos {
            if video.name == newName {
                throw ReframeManagerError.FileAlreadyExists
            }
        }
        
        let fileManager = FileManager.default
        
        var files = try fileManager.contentsOfDirectory(atPath: url!.path)

        for fileName in files {
            if !fileName.hasPrefix("\(oldName).") {
                continue
            }
            let restOfFileName = fileName.dropFirst(oldName.count)
            let newFileName = "\(newName)\(restOfFileName)"
            
            var oldFileURL = self.url!
            var newFileURL = self.url!
            
            oldFileURL.appendPathComponent(fileName)
            newFileURL.appendPathComponent(newFileName)
            print("Rename '\(oldFileURL.path)' to '\(newFileURL.path)'.")
            try fileManager.moveItem(at: oldFileURL, to: newFileURL)
        }
        
        // remove Video360 object from array
        for(index, video) in videos.enumerated() {
            if video.name == oldName {
                videos.remove(at: index)
            }
        }
        
        files = try fileManager.contentsOfDirectory(atPath: url!.path)
        
        // re-enter newly named files
        for file in files {
            if !file.hasPrefix("\(newName).") {
                continue
            }
            
            let fileItem = try getFileInfo(file: file, fileManager: fileManager)
            
            if fileItem.isKnownType {
                addFile(fileItem)
            }
        }
        // loadDirectory()
    }
    
}

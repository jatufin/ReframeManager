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

let DEFAULT_REFRAME_NAME = "Unknown"

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

class Video360: Hashable, Comparable, ObservableObject {
    var name: String
    var previewImageFile: FileItem?
    
    var highDef360File: Video360File?
    var lowDef360File: Video360File?
    
    @Published var reframeFiles = [ReframeFile]()
    var otherFiles = [FileItem]()       // normally this should remain empty
    
    var timeStamp: String {
        if highDef360File != nil {
            return highDef360File!.creationTimeStamp
        }
        
        if lowDef360File != nil {
            return lowDef360File!.creationTimeStamp
        }
        
        return "--/--/--"
    }
    
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
    
    static func < (lhs: Video360, rhs: Video360) -> Bool {
        lhs.name < rhs.name
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
    
    // Add a reframe file to the list
    func addReframeFile(reframeName: String, directory: Directory) throws {
        guard validName(name: reframeName) else {
            throw ReframeManagerError.InvalidName
        }
        
        let fileURL = try newReframeFileURL(name: reframeName, directory: directory)
        
        try addReframeFile(fileURL: fileURL, directory: directory)
    }
    
    // Add a reframe file to the list
    func addReframeFile(fileURL: URL, directory: Directory) throws {
            let fileManager = FileManager.default
            let fileItem = try directory.getFileInfo(file: fileURL.lastPathComponent, fileManager: fileManager)
            
            directory.addFile(fileItem)
    }
    
    // Generate valid file name
    func newReframeFileName(name: String) throws -> String {
        guard validName(name: name) else {
            throw ReframeManagerError.InvalidName
        }
        
        for reframeFile in reframeFiles {
            if reframeFile.reframeName == name {
                throw ReframeManagerError.FileAlreadyExists
            }
        }
        
        let ext = FileExtensions["reframe"]!
        let fileName = "\(self.name).\(name).\(ext)"
        
        return fileName
    }
    
    // Generate valid file URL
    func newReframeFileURL(name: String, directory: Directory) throws -> URL {
        guard var fileURL = directory.videoDirURL else {
            throw ReframeManagerError.DirectoryNotFound
        }
        
        let fileName = try newReframeFileName(name: name)
            
        fileURL.appendPathComponent(fileName)
        
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: fileURL.path) {
            throw ReframeManagerError.FileAlreadyExists
        }
        
        return fileURL
    }
    
    // Create automatically reframe file with given prefix: "MyReframe 1",
    // "MyReframe 2" etc.
    func newReframeFileURL(prefix: String, directory: Directory, automatic: Bool) -> URL {
        var fileURL = URL(fileURLWithPath: "")
        
        for i in 1...10000000 {
            let reframeName = "\(prefix) \(i)"
            
            do {
                fileURL = try newReframeFileURL(name: reframeName,
                                                directory: directory)
                break
            } catch {
                continue
            }
        }
        
        return fileURL
    }
    
    // Remove a reframe file
    func deleteReframe(reframeFile: ReframeFile) throws {
        
        let fileManager = FileManager.default
        try fileManager.removeItem(at: reframeFile.fileItem.url)
        
        if let index = reframeFiles.firstIndex(of: reframeFile) {
            reframeFiles.remove(at: index)
        }
    }
    
    func copyReframe(reframeFile: ReframeFile, newName: String, directory: Directory) throws {
        guard var fileURL = directory.videoDirURL else {
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

    // Two directories are stored in UserDefaults: current working
    // directory, and directory of Player Bundle
    // Both are stored in two ways: The direct URL and secure scoped
    // bookmark. The latter allows us to open the directories again
    // in sandboxed environment
    static let WORKDIR_KEY = "workdir"
    static let WORKDIR_BOOKMARK_KEY = "workdirBM"
    private let DEFAULT_WORKDIR = "~/Documents/"

    static let PLAYERDIR_KEY = "playerdir"
    static let PLAYERDIR_BOOKMARK_KEY = "playerdirBM"
    private let DEFAULT_PLAYERDIR = "~/Library/Containers/com.gopro.GoPro-Player/Data/Library/Application Support/"

    @Published var videoDirURL: URL? { didSet { loadDirectory() }}
    @Published var playerDirURL: URL?
    @Published var videos = [Video360]()
    
    var path: String { videoDirURL?.path ?? "" }
    
    init() {
        
        // Set stored URL:s to set constants, if they were not set
        if UserDefaults.standard.url(forKey: Directory.WORKDIR_KEY) == nil {
            let workDirURL = URL(fileURLWithPath: NSString(string: DEFAULT_WORKDIR).expandingTildeInPath)
            UserDefaults.standard.set(workDirURL, forKey: Directory.WORKDIR_KEY)
        }
        
        if UserDefaults.standard.url(forKey: Directory.PLAYERDIR_KEY) == nil {
            let playerDirURL = URL(fileURLWithPath: NSString(string: DEFAULT_PLAYERDIR).expandingTildeInPath)
            UserDefaults.standard.set(playerDirURL, forKey: Directory.PLAYERDIR_KEY)
        }
        
        // try to open stored secure bookmarks
        videoDirURL = openSecureBookmark(key: Directory.WORKDIR_BOOKMARK_KEY)
        playerDirURL = openSecureBookmark(key: Directory.PLAYERDIR_BOOKMARK_KEY)
    }
    
    func storeSecureBookmark(url: URL, key: String) {
        var data: Data = Data()
        do {
            data = try url.bookmarkData(options: .withSecurityScope,
                                        includingResourceValuesForKeys: nil,
                                        relativeTo: nil)
        } catch {
            return
        }

        _ = url.startAccessingSecurityScopedResource()
        
        UserDefaults.standard.set(data, forKey: key)
    }
    
    func openSecureBookmark(key: String) -> URL? {
        
        guard let data = UserDefaults.standard.data(forKey: key) else {
            
            return nil
        }
        var returnURL = URL(fileURLWithPath: "")
        var isStale = false
        
        do {
            returnURL = try URL(resolvingBookmarkData: data,
                                options: .withSecurityScope,
                                relativeTo: nil,
                                bookmarkDataIsStale: &isStale)
        
        } catch {
            return nil
        }
        
        _ = returnURL.startAccessingSecurityScopedResource()
        
        return returnURL
    }
    
    func loadDirectory() {
        videos = [Video360]()
        var fileItems: [FileItem]
        
        do {
            fileItems = try loadDir()
        } catch {
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
        guard videoDirURL != nil else {
            return [FileItem]()
        }
        
        var fileItems = [FileItem]()
        let fileManager = FileManager.default
        
        let files = try fileManager.contentsOfDirectory(atPath: videoDirURL!.path)
            
        for file in files {
            let fileItem = try getFileInfo(file: file, fileManager: fileManager)
                
            if fileItem.isKnownType {
                fileItems.append(fileItem)
            }
        }
        
        return fileItems
    }
    
    func getFileInfo(file: String, fileManager: FileManager) throws -> FileItem {
        var fileURL = self.videoDirURL!
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
        guard videoDirURL != nil else {
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
        
        var files = try fileManager.contentsOfDirectory(atPath: videoDirURL!.path)

        for fileName in files {
            if !fileName.hasPrefix("\(oldName).") {
                continue
            }
            let restOfFileName = fileName.dropFirst(oldName.count)
            let newFileName = "\(newName)\(restOfFileName)"
            
            var oldFileURL = self.videoDirURL!
            var newFileURL = self.videoDirURL!
            
            oldFileURL.appendPathComponent(fileName)
            newFileURL.appendPathComponent(newFileName)
            try fileManager.moveItem(at: oldFileURL, to: newFileURL)
        }
        
        // remove Video360 object from array
        for(index, video) in videos.enumerated() {
            if video.name == oldName {
                videos.remove(at: index)
            }
        }
        
        files = try fileManager.contentsOfDirectory(atPath: videoDirURL!.path)
        
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

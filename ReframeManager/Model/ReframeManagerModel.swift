//
//  ReframeManagerModel.swift
//  ReframeManager
//
//  Created by Janne Tuukkanen on 7.11.2020.
//  Copyright © 2020 Ibfekna. All rights reserved.
//

import Foundation

struct FileExtensions {
    static let highDef = "360"
    static let lowDef = "LRV"
    static let reframe = "reframe"
}

class FileItem {
    var name: String
    var size: Int
    var creationTime: Date
    var modificationTime: Date
    
    var videoName: String {
        let a = name.components(separatedBy: ".")
        return a[0]
    }
    
    var fileExtension: String {
        let a = name.components(separatedBy: ".")
        return a[a.count - 1]
    }

    internal init(name: String, size: Int, creationTime: Date, modificationTime: Date) {
        self.name = name
        self.size = size
        self.creationTime = creationTime
        self.modificationTime = modificationTime
    }
}

class Video360File: FileItem {
    var creationTimeStamp: String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd-HH-mm-ss-000ZZZ"
        return df.string(from: creationTime)
    }
    
    // This reframe file name is used by the Player app
    var reframeEditFileName: String {
        "\(creationTimeStamp)-\(size).\(FileExtensions.reframe)"
    }
}

class ReframeFile: FileItem {
    // Part of the file name between the first and last dots
    var reframeName: String {
        let a = name.components(separatedBy: ".")
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
    
    var reframeFiles: [ReframeFile]
}

struct Directory {
    var url: URL
    var videos: [String : Video360]
}

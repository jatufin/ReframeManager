//
//  DirectorySelectorView.swift
//  ReframeManager
//
//  Created by Janne Tuukkanen on 9.11.2020.
//  Copyright © 2020 Ibfekna. All rights reserved.
//

import SwiftUI

struct DirectorySelectorView: View {
    @ObservedObject var directory: Directory
    
    var body: some View {
        VStack {
            HStack {
                Button(action: openWorkDir) { Text("Open folder") }
                    
                Spacer()
                Text(directory.url?.path ?? "<Not selected>")
                    .font(.subheadline)
            }
            HStack {
                Button(action: openPlayerDir) { Text("Select Player App folder") }
                Spacer()
                Text(directory.playerDirURL?.path ?? "<Not selected>")
                    .font(.subheadline)
            }
        }
    }
    
    func openWorkDir() {
        var url = directory.playerDirURL
        
        if url == nil {
            url = URL(fileURLWithPath: NSString(string: Directory.DEFAULT_WORKDIR).expandingTildeInPath)
        }
        
        if let dir = selectDirectory(current: url!) {
            directory.url = dir
        }
    }
     
    func openPlayerDir() {
        var url = directory.playerDirURL
        
        if url == nil {
            url = URL(fileURLWithPath: NSString(string: Directory.DEFAULT_PLAYERDIR).expandingTildeInPath)
        }
        
        if let dir = selectDirectory(current: url!) {
            directory.playerDirURL = dir
        }
    }
     
    func selectDirectory(current: URL) -> URL? {
        print("Current: \(current)")
        let openPanel = NSOpenPanel()
        openPanel.directoryURL = current
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        
        let response = openPanel.runModal()
        if response == .cancel {
            return nil
        }
        return openPanel.url ?? current
    }
}

struct DirectorySelectorView_Previews: PreviewProvider {
    static var previews: some View {
        DirectorySelectorView(directory: Directory())
    }
}

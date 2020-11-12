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
                Text(directory.url?.path ?? "<Not selected>")
                Spacer()
                Button(action: openWorkDir) { Text("Open") }
            }
            HStack {
                Text(directory.playerDirURL?.path ?? "<Not selected>")
                Spacer()
                Button(action: openPlayerDir) { Text("Open") }
            }
        }
    }
    
    func openWorkDir() {
        var url = directory.playerDirURL
        
        if url == nil {
            url = URL(fileURLWithPath: NSString(string: Directory.DEFAULT_WORKDIR).expandingTildeInPath)
        }
        
        directory.url = selectDirectory(current: url!)
    }
     
    func openPlayerDir() {
        var url = directory.playerDirURL
        
        if url == nil {
            url = URL(fileURLWithPath: NSString(string: Directory.DEFAULT_PLAYERDIR).expandingTildeInPath)
        }
        
        directory.playerDirURL = selectDirectory(current: url!)
    }
     
    func selectDirectory(current: URL) -> URL {
        print("Current: \(current)")
        let openPanel = NSOpenPanel()
        openPanel.directoryURL = current
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        
        openPanel.runModal()
       
        return openPanel.url ?? current
    }
}

struct DirectorySelectorView_Previews: PreviewProvider {
    static var previews: some View {
        DirectorySelectorView(directory: Directory())
    }
}

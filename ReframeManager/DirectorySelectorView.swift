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
        DirectorySelectorView.openWorkDir(directory)
    }
    
    static func openWorkDir(_ directory: Directory) {

        let url = UserDefaults.standard.url(forKey: Directory.WORKDIR_KEY)
        
        if let dir = DirectorySelectorView.selectDirectory(current: url!) {
            UserDefaults.standard.set(dir, forKey: Directory.WORKDIR_KEY)
            directory.url = dir
        }
    }
    
    func openPlayerDir() {
        DirectorySelectorView.openPlayerDir(directory)
    }
    
    static func openPlayerDir(_ directory: Directory) {

        let url = UserDefaults.standard.url(forKey: Directory.PLAYERDIR_KEY)
        
        if let dir = DirectorySelectorView.selectDirectory(current: url!) {
            UserDefaults.standard.set(dir, forKey: Directory.WORKDIR_KEY)
            directory.playerDirURL = dir
        }
    }
    static func foo() { print("Foo!") }
    
    static func selectDirectory(current: URL) -> URL? {
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

//
//  VideoInfoView.swift
//  ReframeManager
//
//  Created by Janne Tuukkanen on 14.11.2020.
//  Copyright © 2020 Ibfekna. All rights reserved.
//

import SwiftUI


struct VideoInfoView: View {
    @ObservedObject var directory: Directory
    @ObservedObject var video: Video360
    
    @State var displayErrorAlert = false
    @State var errorTitle = ""
    @State var errorMessage = ""
    @State var errorButton = ""
    
    @State var displayConfirmationSheet = false
    @State var confirmationTitle = ""
    @State var confirmationMessage = ""
    @State var confirmationTextValue = ""
    @State var confirmationOkOperation: () -> () = {}
    @State var confirmationDisplayTextField = false
    @State var confirmationSelection = false
    @State var confirmationShowCancel = true
    
    @State var selectedReframe: ReframeFile?
    
    @State var disableView = false
    
    var body: some View {
        VStack {
            HStack {
                Text(video.name).font(.largeTitle)
                Button(action: renameVideo) { Text("Rename") }
            }
            PreviewImageView(width: 300, url: video.previewImageFile?.url ?? nil)
            
            Button(action: { self.editInPlayer(video360File: self.video.highDef360File) }) {
                Text("Edit High Definition") }
            
            Button(action: { self.editInPlayer(video360File: self.video.lowDef360File) }) {
            Text("Edit Low Definition") }
            
            ReframeListView(reframeFiles: video.reframeFiles, selectedReframe: $selectedReframe)
                .padding()
            
            HStack {
                Spacer()
                Button(action: { self.renameReframe() }) { Text("Rename") }
                Button(action: { self.copyReframe() }) { Text("Copy") }
                Button(action: { self.deleteReframe() }) { Text("Delete") }
            }
            .disabled(selectedReframe == nil)
            .padding()
        }
        .alert(isPresented: $displayErrorAlert) {
            Alert(title: Text(self.errorTitle),
                  message: Text(self.errorMessage),
                  dismissButton: .default(Text("OK")))
        }
        .sheet(isPresented: $displayConfirmationSheet) {
            ConfirmationView(
                title: self.confirmationTitle,
                message: self.confirmationMessage,
                textValue: self.$confirmationTextValue,
                displayTextField: self.confirmationDisplayTextField,
                okOperation: self.confirmationOkOperation,
                showCancel: self.confirmationShowCancel,
                displayConfirmationSheet: self.$displayConfirmationSheet
            )
        }
        .disabled(disableView)
    }

    
    func editInPlayer(video360File: Video360File?) {
        print("EDIT")
        guard video360File != nil else {
            errorAlert("Video file missing")
            return
        }

        guard directory.playerDirURL != nil else {
            errorAlert("Player App directory not selected.")
            return
        }
        
        guard directory.url != nil else {
            errorAlert("Directory not selected")
            return
        }
        
        do {
            let fileManager = FileManager.default
            
            var videoURL = directory.url!
            videoURL.appendPathComponent(video360File!.fileItem.name)
            
            
            var editingURL = directory.playerDirURL!
            editingURL.appendPathComponent(video360File!.reframeEditFileName)
            
            var backupURL = editingURL
            backupURL.appendPathExtension(FileExtensions["backup"]!)
            
            let backUp = fileManager.fileExists(atPath: editingURL.path)
            
            if backUp {
                try fileManager.moveItem(at: editingURL, to: backupURL)
            }

            var reframeURL = directory.url!
            if selectedReframe != nil {
                reframeURL.appendPathComponent(selectedReframe!.fileItem.name)
                try fileManager.moveItem(at: reframeURL, to: editingURL)
            } else {
                // Just generating file name for new reframe
                // Player App should create the actual file
                reframeURL = video.newReframeFileURL(prefix: DEFAULT_REFRAME_NAME, directory: directory, automatic: true)
            }
            
            // Launch GoProPlayer
            NSWorkspace.shared.open(videoURL)
            
            confirmationSheet(
                title: "Player is running",
                message: "Wait for the Player to exit. Do not select OK before the Player has shut down!",
                showText: false,
                showCancel: false,
                okOperation: {
                    do {
                        try fileManager.moveItem(at: editingURL, to: reframeURL)
                        
                        if self.selectedReframe == nil {
                            try self.video.addReframeFile(fileURL: reframeURL,
                                                          directory: self.directory)
                        }
                        if backUp {
                            try fileManager.moveItem(at: backupURL, to: editingURL)
                        }
                    } catch {
                        self.errorAlert("Error in edit: \(error)")
                    }
                }
            )
        } catch {
            errorAlert("Error in edit: \(error)")
        }
    }
    
    func renameVideo() {
        let oldName = self.video.name
 
        confirmationSheet(
            message: "Rename video '\(oldName)' and all accompanying files to:",
            text: oldName,
            showText: true,
            okOperation: {
                do {
                    try self.directory.renameVideo(oldName: oldName, newName: self.confirmationTextValue)
                } catch {
                    self.errorAlert("Can't rename '\(oldName)' to '\(self.confirmationTextValue)'.")
                }
                self.disableView = true
            }
        )
    }
    
    func deleteReframe() {
        guard selectedReframe != nil else {
            self.errorAlert("Reframe not selected.")
            return
        }
        
        let s = selectedReframe?.reframeName ?? "<unknown>"
      
        confirmationSheet(
            message: "Do you relly want to delete '\(s)'?",
            okOperation: {
                print("Delete: \(s)")
                
                do {
                    
                    try self.video.deleteReframe(reframeFile: self.selectedReframe!)
                    self.selectedReframe = nil
                    
                } catch {
                    self.errorAlert("Cant delete reframe '\(s)'")
                }
            }
        )
    }
    
    func copyReframe() {
        guard selectedReframe != nil else {
            self.errorAlert("Reframe not selected.")
            return
        }
        
        let oldName = selectedReframe?.reframeName ?? ""
 
        confirmationSheet(
            message: "Copy '\(oldName)' to new name:",
            text: oldName,
            showText: true,
            okOperation: {
                print("Copy \(oldName) to \(self.confirmationTextValue)")
                
                do {
                    
                    try self.video.copyReframe(reframeFile: self.selectedReframe!,
                                               newName: self.confirmationTextValue,
                                               directory: self.directory)
                    
                } catch {
                    self.errorAlert("Can't copy '\(oldName)' to '\(self.confirmationTextValue)'.")
                }
            }
        )
    }
    
    func renameReframe() {
        guard selectedReframe != nil else {
            self.errorAlert("Reframe not selected.")
            return
        }
        
        let oldName = selectedReframe?.reframeName ?? ""
        print("Copy: \(oldName)")
        
        print("In directory: \(directory.path)")
    
        confirmationSheet(
            message: "Rename '\(oldName)' to new name:",
            text: oldName,
            showText: true,
            okOperation: {
                print("Copy \(oldName) to \(self.confirmationTextValue)")
                
                do {
                    
                    try self.video.copyReframe(reframeFile: self.selectedReframe!,
                                               newName: self.confirmationTextValue,
                                               directory: self.directory)
                    
                    try self.video.deleteReframe(reframeFile: self.selectedReframe!)
                    
                } catch {
                    self.errorAlert("Can't rename '\(oldName)' to '\(self.confirmationTextValue)'.")
                }
            }
        )
    }
    
    func errorAlert(title: String = "Error", buttonText: String = "OK", _ message: String) {
        errorTitle = title
        errorMessage = message
        errorButton = buttonText
        displayErrorAlert = true
    }
    
    func confirmationSheet(title: String = "Are you sure?",
                           message: String,
                           text: String = "",
                           showText: Bool = false,
                           showCancel: Bool = true,
                           okOperation: @escaping () -> ()) {
        confirmationTitle = title
        confirmationMessage = message
        confirmationTextValue = text
        confirmationDisplayTextField = showText
        confirmationShowCancel = showCancel
        confirmationOkOperation = okOperation
        
        displayConfirmationSheet = true
    }
}

struct ReframeListView: View {
    var reframeFiles: [ReframeFile]
    @Binding var selectedReframe: ReframeFile?
    
    var body: some View {
        VStack {
            NavigationView {
                List(reframeFiles, id: \.self, selection: $selectedReframe) { reframeFile in
                        Text(reframeFile.reframeName)
                            .font(.headline)
                }
            }
        }
    }
}




/*
struct VideoInfoView_Previews: PreviewProvider {
    static var previews: some View {
        VideoInfoView()
    }
}
 */

//
//  VideoInfoView.swift
//  ReframeManager
//
//  Created by Janne Tuukkanen on 14.11.2020.
//  Copyright © 2020 Ibfekna. All rights reserved.
//

import SwiftUI


struct VideoInfoView: View {
    var directory: Directory
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
    
    @State var selectedReframe: ReframeFile?
    @State var newName: String = ""
    
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
            
            /*
            Text(video.highDef360File?.fileItem.name ?? "Not found")
            Text(video.highDef360File?.reframeEditFileName ?? "Not found")
            
            Text(video.lowDef360File?.fileItem.name ?? "Not found")
            Text(video.lowDef360File?.reframeEditFileName ?? "Not found")
            */
            
            ReframeListView(reframeFiles: video.reframeFiles, selectedReframe: $selectedReframe)
                .padding()
            
            HStack {
                TextField("New name", text: $newName).font(.title)
                Spacer()
                Button(action: { self.deleteReframe() }) { Text("Delete") }
                Button(action: { self.copyReframe() }) { Text("Copy") }
                Button(action: { self.newReframe() }) { Text("New") }
            }
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
                displayConfirmationSheet: self.$displayConfirmationSheet
            )
        }
    }
    
    func editInPlayer(video360File: Video360File?) {
        print("EDIT")
        guard video360File != nil else {
            errorAlert("Video file missing")
            return
        }
        guard selectedReframe != nil else {
            errorAlert("Reframe not selected")
            return
        }
        guard directory.playerDirURL != nil else {
            errorAlert("Player App directory not selected")
            return
        }
        
        print("Edit: \(video360File!.fileItem.name)")
        print("Reframe: \(selectedReframe!.fileItem.name)")
        print("Reframe edit file: \(video360File!.reframeEditFileName)")
        print("Player dir: \(directory.playerDirURL!.path)")
    }
    
    func deleteReframe() {
        let s = selectedReframe?.reframeName ?? "<unknown>"
        print("Delete: \(s)")
        print("In directory: \(directory.path)")
        
        confirmationSheet(
            message: "Do you relly want to delete '\(s)'?",
            okOperation: {
                print("Delete: \(s)")
            }
        )
    }
    
    func copyReframe() {
        let s = selectedReframe?.reframeName ?? ""
        print("Copy: \(s)")
        print("To: \(newName)")
        print("In directory: \(directory.path)")
    
        confirmationSheet(
            message: "Copy '\(s)' to new name:",
            text: s,
            showText: true,
            okOperation: {
                print("Copy \(s) to \(self.confirmationTextValue)")
            }
        )
    }
    
    func newReframe() {
        let s = selectedReframe?.reframeName ?? ""
        print("Create: \(newName)")
        print("In directory: \(directory.path)")
  
        confirmationSheet(
            message: "Create a new reframe file.",
            text: s,
            showText: true,
            okOperation: {
                print("Create a new reframe: \(self.confirmationTextValue)")
                
                do {
                    try self.video.newReframe(reframeName: self.confirmationTextValue, videoName: self.video.name, directory: self.directory)
                } catch {
                    self.errorAlert("Can't create new reframe '\(self.confirmationTextValue)'")
                }
            }
        )
        
        
    }
    
    func renameVideo() {
        let s = video.name
        confirmationSheet(
            message: "Rename '\(s)' and all its associated files to new name:",
            text: s,
            showText: true,
            okOperation: {
                print("Rename \(s) to \(self.confirmationTextValue)")
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
                           okOperation: @escaping () -> ()) {
        confirmationTitle = title
        confirmationMessage = message
        confirmationTextValue = text
        confirmationDisplayTextField = showText
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
                            .font(.title)
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

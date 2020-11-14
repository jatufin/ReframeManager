//
//  VideoInfoView.swift
//  ReframeManager
//
//  Created by Janne Tuukkanen on 14.11.2020.
//  Copyright © 2020 Ibfekna. All rights reserved.
//

import SwiftUI

struct VideoInfoView: View {
    @State var showReframeFileError = false
    @State var errorTitle = ""
    @State var errorMessage = ""
    
    var directory: Directory
    @ObservedObject var video: Video360
    
    @State var selectedReframe: ReframeFile?
    @State var newName: String = ""
    
    var body: some View {
        VStack {
            Text(video.name)
                //.font(.title)
                
            PreviewImageView(width: 300, url: video.previewImageFile?.url ?? nil)
            
            Text(video.highDef360File?.fileItem.name ?? "Not found")
            Text(video.highDef360File?.reframeEditFileName ?? "Not found")
            
            Text(video.lowDef360File?.fileItem.name ?? "Not found")
            Text(video.lowDef360File?.reframeEditFileName ?? "Not found")
            
            ReframeListView(reframeFiles: video.reframeFiles, selectedReframe: $selectedReframe)
            
            HStack {
                TextField("name", text: $newName)
                Spacer()
                Button(action: { self.deleteReframe() }) { Text("Delete") }
                Button(action: { self.copyReframe() }) { Text("Copy") }
                Button(action: { self.newReframe() }) { Text("New") }
            }
        }
        .alert(isPresented: $showReframeFileError) {
            Alert(title: Text("Error creating reframe file"),
                  message: Text("Couldn't create the file"),
                  dismissButton: .default(Text("OK")))
        }
    }
    
    func deleteReframe() {
        let s = selectedReframe?.reframeName ?? "<unknown>"
        print("Delete: \(s)")
        print("In directory: \(directory.path)")
    }
    
    func copyReframe() {
        let s = selectedReframe?.reframeName ?? "<unknown>"
        // Alert(title: Text("Copy"), message: Text(s))
        // print("In directory: \(directory.path)")
    }
    
    func newReframe() {
        let s = selectedReframe?.reframeName ?? "<unknown>"
        print("Create: \(s)")
        print("In directory: \(directory.path)")
        
        do {
            try video.newReframe(reframeName: newName, videoName: video.name, directory: directory)
        } catch {
            errorTitle = "Error"
            errorMessage = "Can't create new reframe '\(newName)'"
            showReframeFileError = true
        }
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

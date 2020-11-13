//
//  ContentView.swift
//  ReframeManager
//
//  Created by Janne Tuukkanen on 6.11.2020.
//  Copyright © 2020 Ibfekna. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var directory: Directory
    
    var body: some View {
        VStack {
            DirectorySelectorView(directory: self.directory)
            VideoListView(directory: directory)
                
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(directory: Directory())
    }
}

struct VideoListView: View {
    @ObservedObject var directory: Directory
    
    var body: some View {
        VStack {
            Section(header: Text(directory.url?.lastPathComponent ?? "<Not selected>")) {
                NavigationView {
                    List(directory.videos, id: \.self) { video in
                        //Text(video.name)
                        
                        NavigationLink(destination: VideoInfoView(video: video)) {
                            VideoRowView(video: video)
                        }
                        
                    }
                    .listStyle(SidebarListStyle())
                    .frame(width: 400)
                }
            }
        }
    }
}

struct VideoRowView: View {
    var video: Video360
    var body: some View {
        HStack {
            Text(video.name)
                .font(.title)
            Spacer()
            PreviewImageView(width: 150, url: video.previewImageFile?.url ?? nil)
        }
    }
    
}
struct VideoInfoView: View {
    var video: Video360
    @State var selectedReframe: ReframeFile?
    
    var body: some View {
        VStack {
            
            Text(video.name)
                .font(.title)
                
            PreviewImageView(width: 300, url: video.previewImageFile?.url ?? nil)
            
            Text(video.highDef360File?.fileItem.name ?? "Not found")
            Text(video.lowDef360File?.fileItem.name ?? "Not found")
            Button(action: { print(self.selectedReframe?.reframeName ?? "<Empty>") }) { Text("Bar") }
            ReframeListView(reframeFiles: video.reframeFiles, selectedReframe: $selectedReframe)
        }
    }
}

struct PreviewImageView: View {
    var width: CGFloat = 100
    var height: CGFloat = 100
    var url: URL?
    
    var body: some View {
        VStack {
            if url == nil {
                Image(nsImage: NSImage(imageLiteralResourceName: "NSMediaBrowserMediaTypePhotosTemplate32"))
                    .resizable().scaledToFit()
            } else {
                Image(nsImage: NSImage(byReferencing: url!))
                    .resizable().scaledToFit()
            }
        }
        .frame(idealWidth: width, idealHeight: height)
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
            Button(action: { print(self.selectedReframe?.reframeName ?? "<Empty>") }) { Text("Foo") }
        }
    }
}



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
            Spacer()
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
            Section(header: Text(directory.url.lastPathComponent)) {
                NavigationView {
                    List(directory.videos, id: \.self) { video in
                        //Text(video.name)
                        
                        NavigationLink(destination: VideoInfoView(video: video)) {
                            VideoRowView(video: video)
                        }
                        
                    }
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
        }
    }
    
}
struct VideoInfoView: View {
    var video: Video360
    
    var body: some View {
        VStack {
            Text(video.name)
            Text(video.previewImage?.name ?? "Not found")
            Text(video.highDef360File?.fileItem.name ?? "Not found")
            Text(video.lowDef360File?.fileItem.name ?? "Not found")
        }
    }
}

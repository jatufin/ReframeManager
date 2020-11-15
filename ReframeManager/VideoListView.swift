//
//  VideoListView.swift
//  ReframeManager
//
//  Created by Janne Tuukkanen on 14.11.2020.
//  Copyright © 2020 Ibfekna. All rights reserved.
//

import SwiftUI

struct VideoListView: View {
    @ObservedObject var directory: Directory
    
    var body: some View {
        VStack {
            Section(/*header: Text(directory.url?.lastPathComponent ?? "<Not selected>").font(.title)*/) {
                NavigationView {
                    List(directory.videos, id: \.self) { video in
                        //Text(video.name)
                        
                        NavigationLink(destination: VideoInfoView(
                            directory: self.directory, video: video)) {
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


/*
struct VideoListView_Previews: PreviewProvider {
    static var previews: some View {
        VideoListView()
    }
}
 */

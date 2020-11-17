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
                .padding()
            VideoListView(directory: directory)
                
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(directory: Directory())
    }
}



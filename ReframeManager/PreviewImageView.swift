//
//  PreviewImageView.swift
//  ReframeManager
//
//  Created by Janne Tuukkanen on 14.11.2020.
//  Copyright © 2020 Ibfekna. All rights reserved.
//

import SwiftUI

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

struct PreviewImageView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewImageView()
    }
}

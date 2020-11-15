//
//  ConfirmationView.swift
//  ReframeManager
//
//  Created by Janne Tuukkanen on 15.11.2020.
//  Copyright © 2020 Ibfekna. All rights reserved.
//

import SwiftUI

struct ConfirmationView: View {
    var title: String
    var message: String
    @Binding var textValue: String
    var displayTextField: Bool = false
    var okOperation: () -> ()
    
    @Binding var displayConfirmationSheet: Bool

    var body: some View {
        VStack {
            Text(title)
                .font(.title)
                .padding()
            
            if displayTextField {
                TextField(textValue, text: $textValue)
            }
            
            Text(message)
                .padding()
            
            HStack {
                Button("OK") {
                    self.okOperation()
                    self.displayConfirmationSheet.toggle()
                }
                .padding()
                
                Button("Cancel") {
                    self.displayConfirmationSheet.toggle()
                }
                .padding()
            }
            .padding()
        }
        .padding()
    }
}

/*
struct ConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmationView()
    }
}
*/

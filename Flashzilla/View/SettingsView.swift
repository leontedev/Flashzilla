//
//  SettingsView.swift
//  Flashzilla
//
//  Created by Mihai Leonte on 23/12/2019.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var isOnReshuffle: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                Toggle(isOn: $isOnReshuffle) {
                    Text("Reshuffle failed cards")
                }
                
                Spacer()
            }.navigationBarItems(trailing: Button("Done", action: dismiss))
        }
    }
    
    func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
}

//struct SettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingsView()
//    }
//}

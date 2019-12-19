//
//  ContentView.swift
//  Flashzilla
//
//  Created by Mihai Leonte on 18/12/2019.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var timeString: String = "Timer"

    var body: some View {
        
        VStack {
            Text("\(timeString)")
               .onReceive(timer) { time in
                    self.timeString = "\(time)"
               }.padding()
            
            Button(action: {
                self.timer.upstream.connect().cancel()
            }) {
                Text("Stop Timer")
            }.padding()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            print("Moving to the background!")
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            print("Moving back to the foreground!")
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

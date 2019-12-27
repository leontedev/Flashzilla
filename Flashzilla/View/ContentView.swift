//
//  ContentView.swift
//  Flashzilla
//
//  Created by Mihai Leonte on 18/12/2019.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import SwiftUI
import CoreHaptics

struct ContentView: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.accessibilityEnabled) var accessibilityEnabled
    @State private var cards = [Card]() //(repeating: Card.example, count: 10)
    @State private var timeRemaining = 100
    @State private var isActive = true
    @State private var showingEditScreen = false
    @State private var showingSettingsScreen = false
    @State private var isOnReshuffle: Bool = true
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    
    var body: some View {
        ZStack {
            Image(decorative: "background")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Time: \(timeRemaining)")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(Color.black)
                            .opacity(0.75)
                    )
                
                if self.timeRemaining > 0 {
                    ZStack {
                        ForEach(0..<cards.count, id: \.self) { index in
                            CardView(card: self.cards[index]) { isWrongAnswer in
                                withAnimation {
                                    self.removeCard(at: index, wrong: isWrongAnswer)
                                }
                            }
                            .stacked(at: index, in: self.cards.count)
                            .allowsHitTesting(index == self.cards.count - 1)
                            .accessibility(hidden: index < self.cards.count - 1)
                        }
                    }.allowsHitTesting(timeRemaining > 0)
                }
                
                if cards.isEmpty || self.timeRemaining == 0 {
                    Button("Start Again", action: resetCards)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .clipShape(Capsule())
                        .padding(.top)
                }
            }
            
            VStack {
                HStack {
                    Button(action: {
                        self.showingSettingsScreen = true
                    }) {
                        Image(systemName: "gear")
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .clipShape(Circle())
                    }
                    .sheet(isPresented: $showingSettingsScreen) {
                        SettingsView(isOnReshuffle: self.$isOnReshuffle)
                    }
                    
                    Spacer()

                    Button(action: {
                        self.showingEditScreen = true
                    }) {
                        Image(systemName: "plus.circle")
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .clipShape(Circle())
                    }
                    .sheet(isPresented: $showingEditScreen, onDismiss: resetCards) {
                        EditCards()
                    }
                    
                }

                Spacer()
            }
            .foregroundColor(.white)
            .font(.largeTitle)
            .padding()
            
            
            if differentiateWithoutColor || accessibilityEnabled {
                VStack {
                    Spacer()

                    HStack {
                        Button(action: {
                            withAnimation {
                                self.removeCard(at: self.cards.count - 1, wrong: true)
                            }
                        }) {
                            Image(systemName: "xmark.circle")
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .clipShape(Circle())
                        }
                        .accessibility(label: Text("Wrong"))
                        .accessibility(hint: Text("Mark your answer as being incorrect."))
                        Spacer()

                        Button(action: {
                            withAnimation {
                                self.removeCard(at: self.cards.count - 1, wrong: false)
                            }
                        }) {
                            Image(systemName: "checkmark.circle")
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .clipShape(Circle())
                        }
                        .accessibility(label: Text("Correct"))
                        .accessibility(hint: Text("Mark your answer as being correct."))
                    }
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .padding()
                }
            }
        }
        .onAppear(perform: resetCards)
        .onReceive(timer) { time in
            guard self.isActive else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
                var engine: CHHapticEngine?
                do {
                    engine = try CHHapticEngine()
                    try engine?.start()
                } catch {
                    print("There was an error creating the engine: \(error.localizedDescription)")
                }
                
                // The engine stopped; print out why
                engine?.stoppedHandler = { reason in
                    print("The engine stopped: \(reason)")
                }

                // If something goes wrong, attempt to restart the engine immediately
                engine?.resetHandler = {
                    do {
                        try engine?.start()
                    } catch {
                        print("Failed to restart the engine: \(error)")
                    }
                }
                
                let short1 = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 0)
                let short2 = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 0.2)
                let short3 = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 0.4)
                let long1 = CHHapticEvent(eventType: .hapticContinuous, parameters: [], relativeTime: 0.6, duration: 0.5)
                let long2 = CHHapticEvent(eventType: .hapticContinuous, parameters: [], relativeTime: 1.2, duration: 0.5)
                let long3 = CHHapticEvent(eventType: .hapticContinuous, parameters: [], relativeTime: 1.8, duration: 0.5)
                let short4 = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 2.4)
                let short5 = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 2.6)
                let short6 = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 2.8)


                do {
                    let pattern = try CHHapticPattern(events: [short1, short2, short3], parameters: [])
                    let player = try engine?.makePlayer(with: pattern)
                    try player?.start(atTime: 0)
                    
//                    DispatchQueue.main.asyncAfter(deadline: .now()+3.2) {
//                        try? player?.stop(atTime: 3.2)
//                    }
                } catch {
                    print("Failed to play pattern: \(error.localizedDescription).")
                }
                //engine?.stop(completionHandler: nil)
                
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            self.isActive = false
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            if self.cards.isEmpty == false {
                self.isActive = true
            }
        }
    }
    
    
    func removeCard(at index: Int, wrong isWrongAnswer: Bool) {
        guard index >= 0 else { return }
            
        if self.isOnReshuffle, isWrongAnswer {
            let elem = cards.remove(at: index)
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                self.cards.insert(elem, at: 0)
            }
        } else {
            cards.remove(at: index)
        }
        
        if cards.isEmpty {
            isActive = false
        }
    }
    
    func resetCards() {
        timeRemaining = 100
        isActive = true
        loadData()
    }
    
    func loadData() {
        if let data = UserDefaults.standard.data(forKey: "Cards") {
            if let decoded = try? JSONDecoder().decode([Card].self, from: data) {
                self.cards = decoded
            }
        }
    }
}


extension View {
    func stacked(at position: Int, in total: Int) -> some View {
        let offset = CGFloat(total - position)
        return self.offset(CGSize(width: offset, height: offset * 6))
    }
}

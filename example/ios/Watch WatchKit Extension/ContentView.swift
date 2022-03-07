//
//  ContentView.swift
//  Watch WatchKit Extension
//
//  Created by Aaron DeLory on 2/2/22.
//

import SwiftUI
import WatchConnectivity

struct ContentView: View {
    @ObservedObject var session = WatchSessionDelegate()
    @State var count = 0

    var body: some View {
        ScrollView {
            Text("Reachable: \(session.reachable.description)")
            Text("Context: \(session.context.description)")
            Text("Received context: \(session.receivedContext.description)")
            Button("Refresh") { session.refresh() }
            Spacer().frame(height: 8)
            Text("Send")
            HStack {
                Button("Message") { session.sendMessage(["data": "Hello"]) }
                Button("Context") {
                    count += 1
                    session.updateApplicationContext(["data": count])
                }
            }
            Spacer().frame(height: 8)
            Text("Log")
            ForEach(session.log.reversed(), id: \.self) {
                Text($0)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

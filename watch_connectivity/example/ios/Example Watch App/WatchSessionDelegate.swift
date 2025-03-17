//
//  WCSessionDelegate.swift
//  Watch WatchKit Extension
//
//  Created by Aaron DeLory on 2/3/22.
//

import Foundation
import SwiftUI
import WatchConnectivity

class WatchSessionDelegate: NSObject, ObservableObject, WCSessionDelegate {
    private let session = WCSession.default
    
    @Published var reachable = false
    @Published var context = [String: Any]()
    @Published var receivedContext = [String: Any]()
    @Published var log = [String]()
    
    override init() {
        super.init()
        session.delegate = self
        session.activate()
    }
    
    func refresh() {
      DispatchQueue.main.async {
        self.reachable = self.session.isReachable
        self.context = self.session.applicationContext
        self.receivedContext = self.session.receivedApplicationContext
      }
    }
    
    func sendMessage(_ message: [String: Any]) {
        session.sendMessage(message, replyHandler: nil)
        log.append("Sent message: \(message)")
    }
    
    func updateApplicationContext(_ context: [String: Any]) {
        try? session.updateApplicationContext(context)
        log.append("Sent context: \(context)")
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        refresh()
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async { self.log.append("Received message: \(message)") }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        DispatchQueue.main.async { self.log.append("Received context: \(applicationContext)") }
    }
}

//
//  MultiplayerConnectivity.swift
//  Pacman Reloaded
//
//  Created by panlong on 20/3/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol MultiplayerConnectivityDelegate {
    // Call the invitaionHandler block with true to connect the inviting player
    func didReceiveInvitationFromPlayer(playerName: String, invitationHandler: ((Bool) -> Void))
    
    // Found a nearby advertising player
    func browser(foundPlayer playerName: String)
    
    // A nearby player has stopped advertising
    func browser(lostPlayer playerName: String)
    
    // Received data from remote player
    func session(didReceiveData data: NSData, fromPlayer playerName: String)
}

// This is the main class in Network component, it handles network traffic and is also responsible for communication with local game engine
class MultiplayerConnectivity: NSObject, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, MCSessionDelegate {
    var delegate: MultiplayerConnectivityDelegate?
    
    private let playerName: String
    private let peerID: MCPeerID

    private let session: MCSession
    
    private var serviceAdvertiser: MCNearbyServiceAdvertiser?
    private var serviceBrowser: MCNearbyServiceBrowser?
    
    init(name: String) {
        playerName = name
        peerID = MCPeerID(displayName: playerName)

        session = MCSession(peer: peerID)
        
        // finish properties initialization and now call super.init()
        super.init()
        
        session.delegate = self
    }
    
    func sendData(toPlayer players: [String], data: NSData, error: NSErrorPointer) {
        session.sendData(data, toPeers: players, withMode: MCSessionSendDataMode.Reliable, error: error)
    }
    
    // the serviceType should be in the same format as a Bonjour service type
    func startServiceAdvertising(serviceType: String, discoveryInfo: [NSObject: AnyObject]) {
        // if the advertiser is not properly set, reinitialize the advertiser
        if serviceAdvertiser == nil || serviceAdvertiser!.serviceType != serviceType {
            serviceAdvertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: discoveryInfo, serviceType: serviceType)
            serviceAdvertiser!.delegate = self
        }
        
        serviceAdvertiser!.startAdvertisingPeer()
    }
    
    // the serviceType should be in the same format as a Bonjour service type
    func startServiceBrowsing(serviceType: String) {
        // if the browser is not properly set, reset the advertiser
        if serviceBrowser == nil || serviceBrowser!.serviceType != serviceType {
            serviceBrowser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
            serviceBrowser!.delegate = self
        }
        
        serviceBrowser!.startBrowsingForPeers()
    }
    
    func stopServiceAdvertising() {
        if let validAdvertiser = serviceAdvertiser {
            validAdvertiser.stopAdvertisingPeer()
        }
    }
    
    func stopServiceBrowsing() {
        if let validServiceBrowser = serviceBrowser {
            validServiceBrowser.stopBrowsingForPeers()
        }
    }
    
    // MARK: methods required in MCNearbyServiceAdvertiserDelegate
    // Incoming invitation request.  Call the invitationHandler block with YES and a valid session to connect the inviting peer to the session.
    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didReceiveInvitationFromPeer peerID: MCPeerID!, withContext context: NSData!, invitationHandler: ((Bool, MCSession!) -> Void)!) {
        let handler: ((Bool) -> Void) = {shouldConnect in
            invitationHandler(shouldConnect, self.session)
        }
        
        if let validDelegate = delegate {
            validDelegate.didReceiveInvitationFromPlayer(peerID.displayName, invitationHandler: handler)
        }
    }
    
    // MARK: methods required in MCNearbyServiceBrowserDelegate
    // Found a nearby advertising peer
    func browser(browser: MCNearbyServiceBrowser!, foundPeer peerID: MCPeerID!, withDiscoveryInfo info: [NSObject : AnyObject]!) {
        if let validDelegate = delegate {
            validDelegate.browser(foundPlayer: peerID.displayName)
        }
    }
    
    // A nearby peer has stopped advertising
    func browser(browser: MCNearbyServiceBrowser!, lostPeer peerID: MCPeerID!) {
        if let validDelegate = delegate {
            validDelegate.browser(lostPlayer: peerID.displayName)
        }
    }
    
    // MARK: methods required in MCSessionDelegate
    // Remote peer changed state
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        
    }
    
    // Received data from remote peer
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
        if let validDelegate = delegate {
            validDelegate.session(didReceiveData: data, fromPlayer: peerID.displayName)
        }
    }
    
    // Received a byte stream from remote peer
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {
        
    }
    
    // Start receiving a resource from remote peer
    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {
        
    }
    
    // Finished receiving a resource from remote peer and saved the content in a temporary location - the app is responsible for moving the file to a permanent location within its sandbox
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {
        
    }
}
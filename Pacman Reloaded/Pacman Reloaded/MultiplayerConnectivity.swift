//
//  MultiplayerConnectivity.swift
//  Pacman Reloaded
//
//  Created by panlong on 20/3/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import Foundation
import MultipeerConnectivity

// This delegate handles advertising and browsing peers events
protocol MatchPeersDelegate {
    // Call the invitaionHandler block with true to connect the inviting player
    func didReceiveInvitationFromPlayer(playerName: String, invitationHandler: ((Bool) -> Void))
    
    // Found a nearby advertising player
    func browser(foundPlayer playerName: String, withDiscoveryInfo info: [NSObject : AnyObject]?)
    
    // A nearby player has stopped advertising
    func browser(lostPlayer playerName: String)
}

// This delegate handles the data receive events
protocol SessionDataDelegate {
    // The connection status has been changed on the other end
    func session(player playerName: String, didChangeState state: MCSessionState)
    
    // Received data from remote player
    func session(didReceiveData data: NSData, fromPlayer playerName: String)
}

// This is the main class in Network component, it handles network traffic and is also responsible for communication with local game engine
class MultiplayerConnectivity: NSObject {
    var matchDelegate: MatchPeersDelegate?
    var sessionDelegate: SessionDataDelegate?
    
    // self name and peerID
    private let playerName: String
    private let peerID: MCPeerID

    // maintain a mapping from name to peerID
    private var nameToPeerIDDict = [String: MCPeerID]()
    private var nameToSessionIndexDict = [String: Int]()
    
    private var sessions = [MCSession]()
    
    private var serviceAdvertiser: MCNearbyServiceAdvertiser?
    private var serviceBrowser: MCNearbyServiceBrowser?
    
    init(name: String) {
        playerName = name
        peerID = MCPeerID(displayName: playerName)

        // we need at least one session
        var session = MCSession(peer: peerID)
        sessions.append(session)
        
        // finish properties initialization and now call super.init()
        super.init()
        
        session.delegate = self
    }
    
    func sendData(toPlayer players: [String], data: NSData, error: NSErrorPointer) {
        var peerIDs = [[MCPeerID]]()
        for i in 0..<sessions.count {
            peerIDs.append([MCPeerID]())
        }
        
        // map the players to the connected sessions
        for name in players {
            if let id = nameToPeerIDDict[name] {
                if let index = nameToSessionIndexDict[name] {
                    peerIDs[index].append(id)
                }
            }
        }

        // in gaming, we want the data sent reliably
        for i in 0..<sessions.count {
            if !peerIDs[i].isEmpty {
                sessions[i].sendData(data, toPeers: peerIDs[i], withMode: MCSessionSendDataMode.Reliable, error: error)
            }
        }
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
            
            // reset mapping from name to peerID
            nameToPeerIDDict.removeAll(keepCapacity: false)
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
    
    func sendInvitation(toPlayer playerName: String) {
        if let peerID = nameToPeerIDDict[playerName] {
            if let browser = serviceBrowser {
                let index = findAvaliableSessionIndex()
                let session = sessions[index]
                browser.invitePeer(peerID, toSession: session, withContext: nil, timeout: Constants.Network.InvitePlayerTimeout)
                nameToSessionIndexDict[playerName] = index
            }
        }
    }
    
    func disconnect() {
        // disconnect from all sessions
        for session in sessions {
            session.disconnect()
        }
        
        // reinitialize sessions and mappings
        sessions.removeAll(keepCapacity: false)
        var session = MCSession(peer: peerID)
        session.delegate = self
        sessions.append(session)
        
        nameToPeerIDDict.removeAll(keepCapacity: false)
        nameToSessionIndexDict.removeAll(keepCapacity: false)
    }
    
    private func findAvaliableSessionIndex() -> Int {
        // find an avaliable session for the new player
        var index = -1;
        for i in 0..<sessions.count {
            if sessions[i].connectedPeers.count < Constants.Network.MaxNumberOfPeersInOneSession {
                index = i
                break
            }
        }
        
        if index == -1 { // if no avaliable session, we need to create a new one
            var session = MCSession(peer: peerID)
            session.delegate = self
            
            sessions.append(session)
            index = sessions.count
        }
        
        return index
    }
}

extension MultiplayerConnectivity: MCNearbyServiceAdvertiserDelegate {
    // MARK: methods required in MCNearbyServiceAdvertiserDelegate
    // Incoming invitation request.  Call the invitationHandler block with YES and a valid session to connect the inviting peer to the session.
    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didReceiveInvitationFromPeer peerID: MCPeerID!, withContext context: NSData!, invitationHandler: ((Bool, MCSession!) -> Void)!) {
        nameToPeerIDDict[peerID.displayName] = peerID
        
        let handler: ((Bool) -> Void) = {shouldConnect in
            let index = self.findAvaliableSessionIndex()
            self.nameToSessionIndexDict[peerID.displayName] = index
            
            let session = self.sessions[index]
            invitationHandler(shouldConnect, session)
        }

        if let validDelegate = matchDelegate {
            validDelegate.didReceiveInvitationFromPlayer(peerID.displayName, invitationHandler: handler)
        }
    }
}

extension MultiplayerConnectivity: MCNearbyServiceBrowserDelegate {
    // MARK: methods required in MCNearbyServiceBrowserDelegate
    // Found a nearby advertising peer
    func browser(browser: MCNearbyServiceBrowser!, foundPeer peerID: MCPeerID!, withDiscoveryInfo info: [NSObject : AnyObject]!) {
        if let validDelegate = matchDelegate {
            // store that mapping
            nameToPeerIDDict[peerID.displayName] = peerID
            validDelegate.browser(foundPlayer: peerID.displayName, withDiscoveryInfo: info)
        }
    }
    
    // A nearby peer has stopped advertising
    func browser(browser: MCNearbyServiceBrowser!, lostPeer peerID: MCPeerID!) {
        if let validDelegate = matchDelegate {
            validDelegate.browser(lostPlayer: peerID.displayName)
        }
    }
}

extension MultiplayerConnectivity: MCSessionDelegate {
    // MARK: methods required in MCSessionDelegate
    // Remote peer changed state
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        if let validDelegate = sessionDelegate {
            validDelegate.session(player: peerID.displayName, didChangeState: state)
        }
    }
    
    // Received data from remote peer
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
        if let validDelegate = sessionDelegate {
            validDelegate.session(didReceiveData: data, fromPlayer: peerID.displayName)
        }
    }
    
    // We don't support passing stream data or file
    // but it can be implemented easily if needed: add the corresponding methods in the delegate and call the function in delegate
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
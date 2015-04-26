//
//  MultiplayerManagementViewController.swift
//  Pacman Reloaded
//
//  Created by Su Xuan on 5/4/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import SpriteKit
import MultipeerConnectivity

class MultiplayerManagementViewController: GameBackgroundViewController {
    
    @IBOutlet weak var newGameTable: UITableView!
    
    private let newGameIdentifier = Constants.Identifiers.NewGameService
    private var newGames: [String] = []
    private var gameIndices = Dictionary<String, Int>()
    private var connectivity = MultiplayerConnectivity(name: UIDevice.currentDevice().name) // Current iPad name
    
    // information needed to start a new game
    private var pacmanId = 0
    private var hostName: String?
    private var selfName = UIDevice.currentDevice().name
    private var otherPlayersName = [String]()
    private var gameCenter: GameCenter?
    private var mapContent: [Dictionary<String, String>]?
    private var miniMapImage: UIImage?
    
    private var connectedCount = 0
    private var waitingAlertVC: UIAlertController?
    private var disconnectedVC: UIAlertController?
    
    override func viewDidLoad() {
        newGameTable.layer.cornerRadius = CGFloat(19) // TODO Magic number
        newGameTable.delegate = self
        newGameTable.dataSource = self
        newGameTable.alpha = 0.7
        connectivity.matchDelegate = self
        connectivity.sessionDelegate = self
        
        // start browsing for nearby players at start
        connectivity.startServiceBrowsing(newGameIdentifier)
        
        waitingAlertVC = UIAlertController(title: "Waiting Game to Start!", message: "Be Ready!", preferredStyle: UIAlertControllerStyle.Alert)
        disconnectedVC = UIAlertController(title: "Disconncted!", message: "Some Player Disconnected!", preferredStyle: UIAlertControllerStyle.Alert)
        
        super.viewDidLoad()
    }
    
    deinit {
        // stop advertising and browsing for services when deinit
        connectivity.stopServiceAdvertising()
        connectivity.stopServiceBrowsing()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let gameVC = segue.destinationViewController as GameViewController
        
        gameCenter = GameCenter(selfName: selfName, hostName: hostName!, otherPlayersName: otherPlayersName, pacmanId: pacmanId, mapContent: self.mapContent!, connectivity: connectivity)
        gameVC.setupMultiplayerGame(fromMap: mapContent!, pacmanId: pacmanId, isHost: (selfName == hostName!), gameCenter: self.gameCenter!, miniMapImage: miniMapImage!)
    }
    
    @IBAction func createNewGame(sender: AnyObject) {
        var levelSelectionVC = self.storyboard?.instantiateViewControllerWithIdentifier("gameLevelSelection") as GameLevelLoadingViewController
        
        levelSelectionVC.delegate = self
        self.presentViewController(levelSelectionVC, animated: true, completion: nil)
    }
    
    @IBAction func BackToHome(sender: AnyObject) {
        newGameTable.delegate = nil
        newGameTable.dataSource = nil
        connectivity.matchDelegate = nil
        connectivity.sessionDelegate = nil
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension MultiplayerManagementViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Alert to confirm joining game
        var alert = UIAlertController(title: "Joining Game",
            message: "Are you sure to join \(newGames[indexPath.row])?",
            preferredStyle: .Alert)

        // If confirmed, send invitation
        let joinGameAction = UIAlertAction(title: "Yes", style: .Default,
            handler: { (action) -> Void in
                self.hostName = self.newGames[indexPath.row]
                self.connectivity.sendInvitation(toPlayer: self.hostName!)
                
                // try connecting to the host, show an indicator with cancel button
                var gameRoomVC = self.storyboard?.instantiateViewControllerWithIdentifier("gameRoomVC") as NewGameRoomViewController
                
                gameRoomVC.gameRoomDelegate = self
                
                // now the game room viewController will received the information from network
                self.connectivity.matchDelegate = gameRoomVC
                self.connectivity.sessionDelegate = gameRoomVC
                
                self.presentViewController(gameRoomVC, animated: true, completion: nil)
        })
        
        let cancelAction = UIAlertAction(title: "No", style: .Cancel,handler: nil)
        
        alert.addAction(cancelAction)
        alert.addAction(joinGameAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let tableCellIdentifier = Constants.Identifiers.NewGameTableCell
        var cell = tableView.dequeueReusableCellWithIdentifier(tableCellIdentifier) as UITableViewCell
        cell.textLabel!.text = newGames[indexPath.row]
        return cell
    }
}

extension MultiplayerManagementViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newGames.count
    }
}

extension MultiplayerManagementViewController: MatchPeersDelegate {
    func didReceiveInvitationFromPlayer(playerName: String, invitationHandler: ((Bool) -> Void)) {}
    
    func browser(foundPlayer playerName: String, withDiscoveryInfo info: [NSObject : AnyObject]?) {
        newGames.append(playerName)
        gameIndices[playerName] = newGames.count - 1
        newGameTable.reloadData()
    }
    
    func browser(lostPlayer playerName: String) {
        if let index = gameIndices[playerName] {
            newGames.removeAtIndex(index)
            gameIndices.removeValueForKey(playerName)
            newGameTable.reloadData()
        }
    }
}

extension MultiplayerManagementViewController: SessionDataDelegate {
    // The connection status has been changed on the other end
    func session(player playerName: String, didChangeState state: MCSessionState) {
        if let alertVC = waitingAlertVC {
            alertVC.dismissViewControllerAnimated(true, completion: nil)
        }
        
        if let alertVC = disconnectedVC {
            alertVC.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Destructive, handler: nil))
            self.presentViewController(alertVC, animated: true, completion: {
                self.connectedCount = 0
                self.connectivity.startServiceBrowsing(Constants.Identifiers.NewGameService)
            })
        }
    }
    
    // Received data from remote player
    func session(didReceiveData data: NSData, fromPlayer playerName: String) {
        let unarchivedData: AnyObject? = NSKeyedUnarchiver.unarchiveObjectWithData(data)
        if let gameStartData = unarchivedData as? GameNetworkStartData {
            if let alertVC = waitingAlertVC {
                alertVC.dismissViewControllerAnimated(true, completion: {() -> Void in
                    self.performSegueWithIdentifier(Constants.Identifiers.MultiplayerGameSegueIdentifier, sender: nil)
                })
            }
        } else if let gameInitACKData = unarchivedData as? GameNetworkInitACKData {
            // counts the connected peers
            connectedCount = connectedCount + 1
            
            if connectedCount == otherPlayersName.count { // if all clients have received the game init data, we can start the game
                if let alertVC = waitingAlertVC {
                    alertVC.dismissViewControllerAnimated(true, completion: {() -> Void in
                        let gameStartData = GameNetworkStartData()
                        let archivedData = NSKeyedArchiver.archivedDataWithRootObject(gameStartData)
                        self.connectivity.sendData(toPlayer: self.otherPlayersName, data: archivedData, error: nil)
                        self.performSegueWithIdentifier(Constants.Identifiers.MultiplayerGameSegueIdentifier, sender: nil)
                        
                        // reset counter
                        self.connectedCount = 0
                    })
                }
            }
        }
    }
}

extension MultiplayerManagementViewController: GameLevelLoadingDelegate {
    func willCancel(sourceVC: UIViewController) {
    }
    
    func didSelectedLevel(sourceVC: UIViewController, mapContent: [Dictionary<String, String>], miniMapImage: UIImage) {
        self.mapContent = mapContent
        self.miniMapImage = miniMapImage
        
        sourceVC.dismissViewControllerAnimated(true, completion: {() -> Void in
            self.hostNewRoom()
        })
    }
    
    private func hostNewRoom() {
        var gameRoomVC = self.storyboard?.instantiateViewControllerWithIdentifier("gameRoomVC") as NewGameRoomViewController
        gameRoomVC.gameRoomDelegate = self
        
        connectivity.stopServiceBrowsing()
        connectivity.matchDelegate = gameRoomVC
        connectivity.sessionDelegate = gameRoomVC
        
        connectivity.startServiceAdvertising(Constants.Identifiers.NewGameService, discoveryInfo: [NSObject: AnyObject]())
        self.presentViewController(gameRoomVC, animated: true, completion: nil)
    }
}

extension MultiplayerManagementViewController: GameRoomDelegate {
    func startNewGame(sourceVC: UIViewController, allPlayers: [String]) {
        if let mapContent = mapContent {
            let pacmanIds = self.extractPacmanIdsFromMap(mapContent)
            self.mapContent = self.removeExtraPacmans(mapContent, pacmanIds: pacmanIds, count: allPlayers.count + 1)
            
            // send game init data to all clients
            for i in 0..<allPlayers.count {
                let gameInitData = GameNetworkInitData(pacmanId: pacmanIds[i], mapContent: self.mapContent!, miniMapImage: self.miniMapImage!)
                let archivedData = NSKeyedArchiver.archivedDataWithRootObject(gameInitData)
                
                self.connectivity.sendData(toPlayer: [allPlayers[i]], data: archivedData, error: nil)
            }
            
            // init information for self to start the game
            self.pacmanId = pacmanIds[allPlayers.count]
            self.selfName = UIDevice.currentDevice().name
            self.hostName = self.selfName
            self.otherPlayersName = allPlayers
            
            sourceVC.dismissViewControllerAnimated(true, completion: {() -> Void in
                if let alertVC = self.waitingAlertVC {
                    // do not browse or advertise services during the game
                    self.connectivity.stopServiceAdvertising()
                    self.connectivity.stopServiceBrowsing()
                    self.connectivity.matchDelegate = self
                    self.connectivity.sessionDelegate = self
                    
                    if self.otherPlayersName.count > 0 {
                        self.presentViewController(alertVC, animated: true, completion: nil)
                    } else {
                        self.performSegueWithIdentifier(Constants.Identifiers.MultiplayerGameSegueIdentifier, sender: nil)
                    }
                }
            })
        }
    }
    
    func joinNewGame(sourceVC: UIViewController, pacmanId: Int, mapContent: [Dictionary<String, String>], miniMapImage: UIImage) {
        self.mapContent = mapContent
        self.miniMapImage = miniMapImage
        self.pacmanId = pacmanId
        
        sourceVC.dismissViewControllerAnimated(true, completion: {() -> Void in
            self.connectivity.stopServiceAdvertising()
            self.connectivity.stopServiceBrowsing()
            self.connectivity.matchDelegate = self
            self.connectivity.sessionDelegate = self
            
            let gameInitACKData = GameNetworkInitACKData()
            let archivedData = NSKeyedArchiver.archivedDataWithRootObject(gameInitACKData)
            self.connectivity.sendData(toPlayer: [self.hostName!], data: archivedData, error: nil)
            
            if let alertVC = self.waitingAlertVC {
                self.presentViewController(alertVC, animated: true, completion: nil)
            }
        })
    }
    
    func quitGameRoom(sourceVC: UIViewController) {
        sourceVC.dismissViewControllerAnimated(true, completion: {() -> Void in
            self.connectivity.disconnect()
            self.connectivity.matchDelegate = self
            self.connectivity.sessionDelegate = self
            
            self.connectivity.stopServiceAdvertising()
            self.connectivity.startServiceBrowsing(Constants.Identifiers.NewGameService)
        })
    }
    
    private func removeExtraPacmans(mapContent: [Dictionary<String, String>], pacmanIds: [Int], count: Int) -> [Dictionary<String, String>] {
        // if there are more pacmans in the map than players, we need to remove those from the map
        var newMap = [Dictionary<String, String>]()
        let stayingPacmanIds = pacmanIds[0..<count]
        for i in 0..<mapContent.count {
            let gameObject = mapContent[i]
            let type = gameObject["type"]
            if type != "pacman" || (find(stayingPacmanIds, i) != nil) {
                newMap.append(gameObject)
            }
        }
        return newMap
    }
    
    // returns the ids for unneeded pacmans
    private func extractPacmanIdsFromMap(mapContent: [Dictionary<String, String>]) -> [Int]{
        var pacmanIds = [Int]()
        for i in 0..<mapContent.count {
            let gameObject = mapContent[i]
            let type = gameObject["type"]
            if type == "pacman" {
                pacmanIds.append(i)
            }
        }
        return pacmanIds
    }
}

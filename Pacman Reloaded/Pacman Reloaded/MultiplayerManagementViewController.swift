//
//  MultiplayerManagementViewController.swift
//  Pacman Reloaded
//
//  Created by Su Xuan on 5/4/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import SpriteKit
import MultipeerConnectivity

class MultiplayerManagementViewController: UIViewController {
    
    @IBOutlet weak var newGameTable: UITableView!
    
    private let newGameIdentifier = Constants.Identifiers.NewGameService
    private var newGames: [String] = []
    private var gameIndices = Dictionary<String, Int>()
    private var connectivity = MultiplayerConnectivity(name: UIDevice.currentDevice().name) // Current iPad name
    
    private var pacmanId = 0
    private var hostName: String?
    private var selfName: String?
    private var otherPlayersName: [String]?
    private var gameCenter: GameCenter?
    private var mapContent: [Dictionary<String, String>]?
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.blackColor()
        newGameTable.layer.cornerRadius = CGFloat(19) // TODO Magic number
        newGameTable.delegate = self
        newGameTable.dataSource = self
        connectivity.matchDelegate = self
        connectivity.startServiceBrowsing(newGameIdentifier)
    }
    
    deinit {
        println("multi management deinited")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let gameVC = segue.destinationViewController as GameViewController
        gameVC.setupMultiplayerGame(fromMap: mapContent!, pacmanId: pacmanId, isHost: (selfName! == hostName!), gameCenter: self.gameCenter!)
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
                self.connectivity.sendInvitation(toPlayer: self.newGames[indexPath.row])
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
    func session(player playername: String, didChangeState state: MCSessionState) {
        switch state {
        case .Connected:
            // connected with host, enter game and set game scene
            break
        case .Connecting:
            // try connecting to the host, show an indicator with cancel button
            var gameRoomVC = self.storyboard?.instantiateViewControllerWithIdentifier("gameRoomVC") as NewGameRoomViewController
            connectivity.matchDelegate = gameRoomVC
            connectivity.sessionDelegate = gameRoomVC
            self.presentViewController(gameRoomVC, animated: true, completion: nil)
            
            break
        case .NotConnected:
            // there is a problem connecting with the host, show an alert message
            break
        default:
            break
        }
    }
    
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

extension MultiplayerManagementViewController: GameLevelLoadingDelegate {
    func didSelectedLevel(sourceVC: UIViewController, mapContent: [Dictionary<String, String>]) {
        self.mapContent = mapContent
        sourceVC.dismissViewControllerAnimated(true, completion: {() -> Void in
            self.presentGameRoomVC()
        })
    }
    
    private func presentGameRoomVC() {
        var gameRoomVC = self.storyboard?.instantiateViewControllerWithIdentifier("gameRoomVC") as NewGameRoomViewController
        gameRoomVC.gameStartDelegate = self
        
        connectivity.stopServiceBrowsing()
        connectivity.matchDelegate = gameRoomVC
        connectivity.startServiceAdvertising(Constants.Identifiers.NewGameService, discoveryInfo: [NSObject: AnyObject]())
        self.presentViewController(gameRoomVC, animated: true, completion: nil)
    }
}

extension MultiplayerManagementViewController: NewGameStartDelegate {
    func startNewGame(sourceVC: UIViewController, hostName: String, allPlayers: [String]) {
        if let mapContent = mapContent {
            let pacmanIds = extractPacmanIdsFromMap(mapContent)
            self.mapContent = removeExtraPacmans(mapContent, pacmanIds: pacmanIds, count: allPlayers.count + 1)
            
            for i in 0..<allPlayers.count {
                let gameInitData = GameNetworkInitData(hostName: hostName, allPlayersName: allPlayers, pacmanId: pacmanIds[i], mapContent: self.mapContent!)
                connectivity.sendData(toPlayer: [allPlayers[i]], data: gameInitData, error: nil)
            }
            
            self.pacmanId = pacmanIds.last!
            self.selfName = hostName
            self.hostName = hostName
            self.otherPlayersName = allPlayers
            self.gameCenter = GameCenter(selfName: hostName, hostName: hostName, otherPlayersName: allPlayers, pacmanId: pacmanIds.last!, mapContent: self.mapContent!, connectivity: connectivity)
            
            sourceVC.dismissViewControllerAnimated(true, completion: nil)
            
            performSegueWithIdentifier(Constants.Identifiers.MultiplayerGameSegueIdentifier, sender: self)
        }
    }
    
    func joinNewGame(mapContent: [Dictionary<String, String>], pacmanId: Int, selfName: String, hostName: String, otherPlayersName: [String]) {
        self.mapContent = mapContent
        self.pacmanId = pacmanId
        self.selfName = selfName
        self.hostName = hostName
        self.otherPlayersName = otherPlayersName
        self.gameCenter = GameCenter(selfName: selfName, hostName: hostName, otherPlayersName: otherPlayersName, pacmanId: pacmanId, mapContent: mapContent, connectivity: connectivity)
        
        performSegueWithIdentifier(Constants.Identifiers.MultiplayerGameSegueIdentifier, sender: self)
    }
    
    private func removeExtraPacmans(mapContent: [Dictionary<String, String>], pacmanIds: [Int], count: Int) -> [Dictionary<String, String>] {
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
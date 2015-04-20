//
//  MultiplayerGameSceneDelegate.swift
//  Pacman Reloaded
//
//  Created by panlong on 20/4/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import Foundation

protocol MultiplayerGameSceneDelegate {
    // loaded game map, the host vc needs to save the information and forwards to other players
    func didLoadGameMap(content: [Dictionary<String, String>])
}
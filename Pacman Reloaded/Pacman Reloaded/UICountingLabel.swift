//
//  UICountingLabel.swift
//  Pacman Reloaded
//
//  Created by BenMQ on 21/4/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import UIKit

class UICountingLabel: UILabel {

    // time taken for the label to finish updating
    var updateDuration: Double = 0.5
    // update interval
    var updateInterval: Double = 0.1

    private var timer: NSTimer!
    private var currentValue: Int = 0
    private var targetValue: Int = 0
    private var increment: Int = 0

    // override this function to update the output
    func updateText() {
        self.text = "Score: \(currentValue)"
    }

    func update() {
        currentValue += increment
        if currentValue >= targetValue && increment > 0
            || currentValue <= targetValue && increment < 0 {
                currentValue = targetValue
                timer.invalidate()
        }
        self.updateText()
    }

    func updateTo(value: Int) {
        if timer != nil {
            timer.invalidate()
        }
        if value != currentValue {
            targetValue = value
            increment = (targetValue - currentValue) / Int(updateDuration / updateInterval)
        }
        timer = NSTimer.scheduledTimerWithTimeInterval(Double(self.updateInterval), target: self, selector: "update", userInfo: nil, repeats: true)
    }

    deinit {
        if timer != nil {
            timer?.invalidate()
        }
        timer = nil
    }

}

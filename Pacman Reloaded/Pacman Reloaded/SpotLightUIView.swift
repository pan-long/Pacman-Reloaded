//
//  SpotLightUIView.swift
//  Pacman Reloaded
//
//  Created by chuyu on 19/4/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import UIKit

public class SpotLightUIView: UIView {
    private let duration: NSTimeInterval = 0.3
    private var spotLightCenter: CGPoint
    private var spotLightRadius: CGFloat = 150.0
    private var modalOpacity: CGFloat = 1.5
    
    init(spotLightCenter: CGPoint, frame: CGRect) {
        self.spotLightCenter = spotLightCenter
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        self.autoresizingMask = .FlexibleWidth | .FlexibleHeight
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let locations: [CGFloat] = [0.0, 1.0]
        let colors: [CGFloat] = [
            0.0, 0.0, 0.0, 0.0,
            0.0, 0.0, 0.0, modalOpacity]
        let gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, 2)
        
        let gradientCenter = CGPoint(
            x: spotLightCenter.x,
            y: spotLightCenter.y)
        let startPoint = gradientCenter
        let startRadius: CGFloat = 0.0
        let endPoint = gradientCenter
        let endRadius = spotLightRadius
        
        CGContextDrawRadialGradient(context, gradient, startPoint, startRadius, endPoint, endRadius, 2)
    }
}

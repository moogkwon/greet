//
//  LinearGradientLayer.swift
//  GriitChat
//
//  Created by leo on 13/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

//import Foundation

import UIKit


extension UIView {
    
    enum GradientDirection {
        case vertical
        case horizontal
        case custom(start: CGPoint, end: CGPoint)
        var points: (start: CGPoint, end: CGPoint) {
            switch self {
            case .vertical:
                return (CGPoint(x: 0.5, y: 0.0), CGPoint(x: 0.5, y: 1.0))
            case .horizontal:
                return (CGPoint(x: 0.0, y: 0.5), CGPoint(x: 1.0, y: 0.5))
            case let .custom(start, end):
                return (start, end)
            }
        }
    }

    func applyGradient(colours: [CGColor], direction: GradientDirection, frame: CGRect) -> Void {
        let gradientLayer: LinearGradientLayer = LinearGradientLayer();
        
        gradientLayer.colors = colours;
        gradientLayer.direction = direction;
        gradientLayer.frame = CGRect(x: 0, y: 0, width: bounds.width * 1.15, height: bounds.height * 1.15);
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func applyGradient(colours: [UIColor], direction: GradientDirection, frame: CGRect) -> Void {
        applyGradient(colours: colours.map { $0.cgColor }, direction: direction, frame: frame);
    }
    /*
    
    func applyGradient(colours: [UIColor]) -> Void {
        self.applyGradient(colours: colours, locations: nil)
    }
    
    func applyGradient(colours: [UIColor], locations: [NSNumber]?) -> Void {
        applyGradient(colours: colours.map { $0.cgColor }, locations: locations);
    }
    func applyGradient(colours: [CGColor], locations: [NSNumber]?) -> Void {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours
        gradient.locations = locations
        self.layer.insertSublayer(gradient, at: 0)
    }*/
}

final class LinearGradientLayer: CALayer {
    var direction: UIView.GradientDirection = .vertical
    var colorSpace = CGColorSpaceCreateDeviceRGB()
    var colors: [CGColor]?
    var locations: [CGFloat]?
    var options: CGGradientDrawingOptions = CGGradientDrawingOptions(rawValue: 0)
    required override init() {
        super.init()
        masksToBounds = true
        needsDisplayOnBoundsChange = true
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    required override init(layer: Any) {
        super.init(layer: layer)
    }
    override func draw(in ctx: CGContext) {
        ctx.saveGState()
        guard let colors = colors, let gradient = CGGradient(colorsSpace: colorSpace,
                                                             colors: colors as CFArray, locations: locations) else { return }
        let points = direction.points
        
        ctx.drawLinearGradient(
            gradient,
            start: transform(points.start),
            end: transform(points.end),
            options: options
        )
    }
    private func transform(_ point: CGPoint) -> CGPoint {
        return CGPoint(x: bounds.width * point.x, y: bounds.height * point.y)
    }
}

class GradientView: UIView {
    var gradientLayer: LinearGradientLayer;
    /*lazy var gradientLayer: LinearGradientLayer = {
        let gradientLayer = LinearGradientLayer()
        gradientLayer.colors = [UIColor.dodgerBlue.cgColor, UIColor.brightLightBlue.cgColor]
        return gradientLayer
    }()*/
    override init(frame: CGRect) {
        gradientLayer = LinearGradientLayer();
        
        super.init(frame: frame)
//        layer.insertSublayer(gradientLayer, at: 0)
    }
    required init?(coder aDecoder: NSCoder) {
        gradientLayer = LinearGradientLayer();
        
        super.init(coder: aDecoder)
//        layer.insertSublayer(gradientLayer, at: 0)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        
        gradientLayer.colors = [UIColor.dodgerBlue.cgColor, UIColor.brightLightBlue.cgColor];
        layer.insertSublayer(gradientLayer, at: 0)
    }
    func setBackColors(colors: [CGColor]) {
        gradientLayer.colors = colors;
        layer.insertSublayer(gradientLayer, at: 1)
    }
}


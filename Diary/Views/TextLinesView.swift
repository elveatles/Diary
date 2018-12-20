//
//  TextLinesView.swift
//  Diary
//
//  Created by Erik Carlson on 12/20/18.
//  Copyright © 2018 Round and Rhombus. All rights reserved.
//

import UIKit

/// Draws horizontal lines like a sheet of writing paper.
@IBDesignable
class TextLinesView: UIView {
    @IBInspectable var spacing: CGFloat = 20
    @IBInspectable var offset: CGFloat = 0
    @IBInspectable var lineWidth: CGFloat = 2
    @IBInspectable var strokeColor: UIColor = .gray
    var lines = [CAShapeLayer]()
    
    func createLines() {
        if let sublayers = layer.sublayers {
            for sublayer in sublayers {
                sublayer.removeFromSuperlayer()
            }
        }
        
        var yPos = spacing
        while yPos < bounds.height {
            let line = CAShapeLayer()
            let path = UIBezierPath()
            var point = CGPoint(x: 0, y: yPos)
            path.move(to: point)
            point.x = bounds.width
            path.addLine(to: point)
            line.path = path.cgPath
            line.strokeColor = UIColor.gray.cgColor
            line.lineWidth = 2
            layer.addSublayer(line)
            
            yPos += spacing
        }
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setStrokeColor(strokeColor.cgColor)
        context.setLineWidth(lineWidth)
        
        var yPos = spacing + offset
        var point = CGPoint.zero
        while yPos < bounds.height {
            point = CGPoint(x: 0, y: yPos)
            context.move(to: point)
            point.x = bounds.width
            context.addLine(to: point)
            context.strokePath()
            
            yPos += spacing
        }
    }
}

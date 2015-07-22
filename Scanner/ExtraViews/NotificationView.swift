//
//  NotificationView.swift
//  Scanner
//
//  Created by Maxence Ho on 20/07/2015.
//  Copyright (c) 2015 Maxence Ho. All rights reserved.
//


import UIKit

class HudView: UIView {
    
    /*========================================*/
    // Initialization
    
    // MARK: - Instance variables
    var text = ""
    let screenWidth  = UIScreen.mainScreen().bounds.size.width
    
    // MARK: - Style
    override func drawRect(rect: CGRect) {

        let boxWidth:  CGFloat = screenWidth-4
        let boxHeight: CGFloat = 96
        
        let boxRect = CGRect(
            x: 2,
            y: 44,
            width: boxWidth,
            height: boxHeight
        )
        
        let roundedRect = UIBezierPath(roundedRect: boxRect, cornerRadius: 5)
        UIColor(red: 166/255, green: 28/255, blue: 0/255, alpha: 0.5).setFill()
        roundedRect.fill()
        
        // Add text
        let attribs =
        [
            NSFontAttributeName: UIFont.systemFontOfSize(14.0),
            NSForegroundColorAttributeName: UIColor.whiteColor()
        ]
        
        let textSize = text.sizeWithAttributes(attribs)
        
        let textPoint = CGPoint(
            x: center.x - round(textSize.width / 2),
            y: 34 + round(textSize.height / 2) + boxHeight / 4
        )
        
        text.drawAtPoint(textPoint, withAttributes: attribs)
    }
    
    // MARK: - Animations
    func showAnimated(animated: Bool) {
        if animated
        {
            alpha = 0
            transform = CGAffineTransformMakeScale(1.3, 1.3)
            UIView.animateWithDuration(
                1.5,
                delay: 0,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0.5,
                options: UIViewAnimationOptions(0),
                animations:
                {
                    self.alpha = 1
                    self.transform = CGAffineTransformIdentity
                },
                completion: nil
            )
        }
    }
    
    func hideAnimation() {
        alpha = 1
        UIView.animateWithDuration(
            1.5,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.5,
            options: UIViewAnimationOptions(0),
            animations:
            {
                self.alpha = 0
            },
            completion: { finished in
                self.hidden = true
            }
        )
    }

    
    
    // MARK: - Convenience constructor
    class func hudInView(view: UIView, animated: Bool) -> HudView {
        let hudView = HudView(frame: view.bounds)
        hudView.opaque = false
        view.addSubview(hudView)
        view.userInteractionEnabled = true
        hudView.showAnimated(animated)
        return hudView
    }
    
}

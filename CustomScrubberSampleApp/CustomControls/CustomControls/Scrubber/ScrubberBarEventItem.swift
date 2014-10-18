//
//  ScrubberBarEventItem.swift
//  CustomControls
//
//  Created by Brice Pollock on 9/11/14.
//  Copyright (c) 2014 Coursera. All rights reserved.
//

import UIKit

public class ScrubberBarEventItem: UIView {
    
    /** A value 0->1 which represents 0 to 100% of scrubber bar value  **/
    let index: Float
    let color: UIColor
    
    private let radius: CGFloat = 10.0
    private let padding: CGFloat = 3.0
    private var completionClosure: (() -> ())?
    var didEventFire: Bool = false
    var hasCompletionClosure: Bool {
        return (completionClosure != nil)
    }
    
    required public init(index: Float, color: UIColor = UIColor.whiteColor(), completionClosure: ( () -> () )? = nil) {
        
        var validIndex: Float = index
        if index < 0 {
            validIndex = 0
        } else if index > 1 {
            validIndex = 1
        }
        self.index = validIndex
        self.color = color
        self.completionClosure = completionClosure
        
        let frameSize = radius + padding
        super.init(frame: CGRectMake(0, 0, frameSize, frameSize))
        
        backgroundColor = color
        setTranslatesAutoresizingMaskIntoConstraints(false)
    }
    required convenience public init(coder aDecoder: NSCoder) {
        self.init(index:0.0, color:UIColor.whiteColor())
    }
    
    override public func intrinsicContentSize() -> CGSize {
        return CGSizeMake(radius, radius)
    }
    
    override public class func requiresConstraintBasedLayout() -> Bool {
        return true
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height/2
    }
    
    //MARK: Instance Methods
    func fire() {
        didEventFire = true
        if let completion = completionClosure {
            completion()
        }
    }
}
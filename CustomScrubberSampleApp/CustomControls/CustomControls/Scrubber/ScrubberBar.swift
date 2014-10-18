//
//  ScrubberBar.swift
//  CustomControls
//
//  Created by Brice Pollock on 9/11/14.
//  Copyright (c) 2014 Coursera. All rights reserved.
//

import UIKit

struct EventItemConstraints {
    let leading: NSLayoutConstraint
    let height: NSLayoutConstraint
    let width: NSLayoutConstraint
    let center: NSLayoutConstraint
    init(leading: NSLayoutConstraint, height: NSLayoutConstraint, width: NSLayoutConstraint, center: NSLayoutConstraint) {
        self.leading = leading
        self.height = height
        self.width = width
        self.center = center
    }
    
    func asList() -> Array<NSLayoutConstraint> {
        return [leading, height, width, center]
    }
}

class ScrubberBar: UIView {
    
    // Public Properties
    /** 0->1 value for the extent of the buffer bar **/
    var bufferIndex: Float = 0
    var bufferFill: UIView
    let minBufferWidth: CGFloat = 3
    
    // View Children
    private var eventMap = Dictionary<Float, ScrubberBarEventItem>() // <event.index, event>
    
    // UI Constants
    private let intrinsicWidth: CGFloat = 50.0
    private let intrinsicHeight: CGFloat = 35.0
    private let borderWidth: CGFloat = 2.0
    private var scrubBarWidth: CGFloat {
        return frame.width - 2*layer.cornerRadius
    }
    private var scrubBarOrigin: CGFloat {
        return frame.origin.x + layer.cornerRadius
    }
    
    // Constraint Properties
    private var eventConstraintDictionary = Dictionary<ScrubberBarEventItem, EventItemConstraints>()
    
    //MARK: Fundamental Methods
    override convenience init() {
        self.init(frame: CGRectZero)
    }
    
    override init(frame: CGRect) {
        bufferFill = UIView(frame: CGRectMake(frame.origin.x, frame.origin.y, 0, frame.height))
        super.init(frame: frame)
        setTranslatesAutoresizingMaskIntoConstraints(false)
        setupViews()
    }
    
    convenience required init(coder aDecoder: NSCoder) {
        self.init(frame: CGRectZero)
    }
    
    func setupViews() {
        layer.borderWidth = borderWidth
        
        // Setup the buffer fill
        addSubview(bufferFill)
        bufferFill.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        var bufferConstraints = Array<NSLayoutConstraint>()
        bufferConstraints.append(NSLayoutConstraint(item: bufferFill, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Height, multiplier: 0.95, constant: 0.0))
        bufferConstraints.append(NSLayoutConstraint(item: bufferFill, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 0.0))
        bufferConstraints.append(NSLayoutConstraint(item: bufferFill, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0.0))
        bufferConstraints.append(NSLayoutConstraint(item: bufferFill, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Width, multiplier: 1.0, constant: -1.0))
        
        addConstraints(bufferConstraints)
    }
    
    override func intrinsicContentSize() -> CGSize {
        return CGSizeMake(intrinsicWidth, intrinsicHeight)
    }
    
    override class func requiresConstraintBasedLayout() -> Bool {
        return true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let cornerRadius = frame.height/2
        layer.cornerRadius = cornerRadius
        
        // A minimum value is necessary so that the left side round can be drawn within the bounds of the ScrubberBar
        var newBufferFillFrameWidth = CGFloat(bufferIndex)*frame.width
        if newBufferFillFrameWidth < minBufferWidth {
            newBufferFillFrameWidth = minBufferWidth
        }
        
        // Update display for buffer fill view
        let fullCornerBreakPoint = frame.width - 0.5*cornerRadius // tweaked point at which fill enters the scrubberBar corner enough to warrent rounded corners on both sides of view
        if (newBufferFillFrameWidth >= fullCornerBreakPoint) {
            bufferFill.layer.mask = nil
            bufferFill.layer.cornerRadius = cornerRadius
        } else {
            // If the buffer fill is not near the end of the scrubber we will only draw the left as a rounded corner
            let newFrame = CGRectMake(bufferFill.frame.origin.x, bufferFill.frame.origin.y, newBufferFillFrameWidth, bufferFill.frame.height)
            drawLeftRoundedCorner(newFrame)
        }
        
        // Update all events and add any added since last layout
        for (eventIndex, event) in eventMap {
            addSubview(event)
            
            let eventItemDiameter = frame.height - 4*borderWidth
            event.layer.cornerRadius = eventItemDiameter/2
            let leadingValue = leadingValueForItem(eventItemDiameter, index: event.index)
            if let eventConstraints = eventConstraintDictionary[event] {
                eventConstraints.leading.constant = leadingValue
                eventConstraints.height.constant = eventItemDiameter
                eventConstraints.width.constant = eventItemDiameter
                continue
            }
            
            var leadingConstraint = NSLayoutConstraint(item: event, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: leadingValue)
            
            var heightConstraint = NSLayoutConstraint(item: event, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: eventItemDiameter)
            
            var widthConstraint = NSLayoutConstraint(item: event, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: eventItemDiameter)
            
            var centerConstraint = NSLayoutConstraint(item: event, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0.0)
            
            let eventConstraints = EventItemConstraints(leading: leadingConstraint, height: heightConstraint, width: widthConstraint, center: centerConstraint)
            eventConstraintDictionary[event] = eventConstraints
            addConstraints(eventConstraints.asList())
        }
    }
    
    func drawLeftRoundedCorner(frame: CGRect) {
        // Lay out the coordinates
        let cornerRadius = 0.5*frame.height
        let endAngle = CGFloat(M_PI + M_PI_2)
        let startPoint = CGPointMake(frame.origin.x + frame.width, frame.origin.y + frame.height)
        let arcStart = CGPointMake(frame.origin.x + cornerRadius, frame.origin.y + frame.height)
        let arcCenter = CGPointMake(frame.origin.x + cornerRadius, frame.origin.y + cornerRadius)
        let arcEnd = CGPointMake(frame.origin.x + cornerRadius, frame.origin.y)
        let endPoint = CGPointMake(frame.origin.x + frame.width, frame.origin.y)
        
        // draw the path
        let newPath = UIBezierPath()
        newPath.moveToPoint(startPoint)
        newPath.addLineToPoint(arcStart)
        newPath.addArcWithCenter(arcCenter, radius: cornerRadius, startAngle: CGFloat(M_PI_2), endAngle: endAngle, clockwise: true)
        newPath.addLineToPoint(endPoint)
        newPath.closePath()
        
        // Add the mask
        var roundingMaskLayer = CAShapeLayer()
        roundingMaskLayer.frame = bufferFill.bounds
        roundingMaskLayer.path = newPath.CGPath
        bufferFill.layer.mask = roundingMaskLayer
    }
    
    //MARK: Event Methods
    
    func addEvents(events: Array<ScrubberBarEventItem>) {
        for event in events {
            eventMap[event.index] = event
        }
        layoutSubviews()
    }
    
    func addEvent(event:ScrubberBarEventItem) {
        eventMap[event.index] = event
        layoutSubviews()
    }
    
    func removeEventAtIndex(index: Float) {
        eventMap.removeValueForKey(index)
    }
    
    func events() -> Array<ScrubberBarEventItem> {
        let immutableEventList = Array(eventMap.values)
        return immutableEventList
    }
    
    //MARK: Helper Methods
    
    /**
    Get the leading constant for leading constraint
    
    :param: width Width of item
    :param: index Expected index position of the item (0 -> 1)
    
    :returns: Leading constraint constant for a view on the scrubber bar. Zero if invalid index
    */
    func leadingValueForItem(width: CGFloat, index: Float) -> CGFloat {
        if index < 0 || index > 1 || width < 0 {
            return 0
        }
        
        return (scrubBarWidth * CGFloat(index)) - 0.5*width + layer.cornerRadius
    }
    
    /**
    
    */
    /**
    Transform an xCoord so its guarenteed to be on the scrubber bar axis
    
    :param: xCoord       Current x-coordinate of the view to santitize center for
    
    :returns: x-coordinate guarenteed to be on scrubber bar axis
    */
    func sanitizeCenterXCoord(xCoord: CGFloat) -> CGFloat {
        var touchBarCoord: CGFloat = 0
        let frameMinValue = scrubBarOrigin
        let frameMaxValue = scrubBarOrigin + scrubBarWidth
        if xCoord < frameMinValue {
            touchBarCoord = frameMinValue
        } else if xCoord > frameMaxValue {
            touchBarCoord = frameMaxValue
        } else {
            touchBarCoord = xCoord
        }
        return touchBarCoord
    }
    
    /**
    Translate an xCoordinate into a scrubberBar index
    
    :param: xCoord       Current x-coordinate of the view to calculate index for
    :param: elementWidth Current width of view to calculate the index for
    
    :returns: Index as float from 0->1
    */
    func indexForCoord(xCoord: CGFloat) -> Float {
        let xCoordIndex = sanitizeCenterXCoord(xCoord) - scrubBarOrigin
        return Float(xCoordIndex / scrubBarWidth)
    }
    
}
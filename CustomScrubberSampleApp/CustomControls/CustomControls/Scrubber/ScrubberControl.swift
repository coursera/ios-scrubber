//
//  ScrubberControl.swift
//  CustomControls
//
//  Created by Brice Pollock on 9/11/14.
//  Copyright (c) 2014 Coursera. All rights reserved.
//

import UIKit

/**
Use these methods to perform work when control events such as scrubbing occur
*/
public protocol ScrubberControlEventsDelegate {
    func scrubDidBegan()
    func didScrubToValue(value: Float)
    func scrubDidEnd()
}

@IBDesignable public class ScrubberControl: UIView {
    
    // Private Properties
    private var didSetMaximumValue = false
    
    // Public Properties
    public var maximumValue: Float = 1 {
        didSet {
            didSetMaximumValue = true
            self.layoutSubviews()
        }
    }
    public var minimumValue: Float = 0
    public var currentValue: Float = 0 {
        didSet {
            if !didSetMaximumValue && currentValue > maximumValue {
                println("WARNING - Have not yet set maximum value, setting the current value here could trigger some events to fire unexpectedly")
            }
            
            self.scrubberElement.index = currentIndex
            self.evaluateEventItems()
            self.layoutSubviews()
        }
    }
    public weak var valueLabel: UILabel? {
        get {
            return self.scrubberElement.timeLabel
        }
    }
    public var duration: Float {
        get {
            return maximumValue - minimumValue
        }
    }
    public var bufferExtent: Float {
        set (newValue) {
            var bufferIndex: Float = 0
            if duration > 0 {
                bufferIndex = newValue / duration
            }
            
            self.scrubberBar.bufferIndex = bufferIndex
            self.scrubberBar.layoutSubviews()
        }
        get {
            return self.scrubberBar.bufferIndex * duration
        }
    }
    
    public var delegate: ScrubberControlEventsDelegate?
    
    //FIXME: Right now this control is Timing out in IB.
    @IBInspectable public var scrubberBarColor: UIColor = UIColor(red: 164/255, green: 164/255, blue: 164/255, alpha: 1.0) {
        didSet {
            updateColoring()
        }
    }
    @IBInspectable public var scrubberBarBorderColor: UIColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1.0) {
        didSet {
            updateColoring()
        }
    }
    
    @IBInspectable public var backgroundViewColor: UIColor = UIColor.clearColor() {
        didSet {
            updateColoring()
        }
    }
    
    @IBInspectable public var scrubberColor: UIColor = UIColor.whiteColor() {
        didSet {
            updateColoring()
        }
    }
    
    @IBInspectable public var bufferFillColor: UIColor = UIColor(red: 188/255, green: 188/255, blue: 188/255, alpha: 1.0) {
        didSet {
            updateColoring()
        }
    }
    
    // Other Properties
    private var currentIndex: Float {
        get {
            if duration == 0 {
                return 0
            }
            return currentValue / duration
        }
    }
    var scrubberElement = ScrubberElement()
    var scrubberBar = ScrubberBar()
    
    private var scrubberElementCenterConstraint: NSLayoutConstraint?
    
    //MARK: Fundamental Methods
    
    required public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
        self.setupViews()
        self.setupLayout()
        self.updateColoring()
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
        self.setupViews()
        self.setupLayout()
        self.updateColoring()
    }
    
    func updateColoring() {
        scrubberElement.elementColor = scrubberColor
        scrubberBar.bufferFill.backgroundColor = bufferFillColor
        scrubberBar.backgroundColor = scrubberBarColor
        scrubberBar.layer.borderColor = scrubberBarBorderColor.CGColor
        layer.backgroundColor = backgroundViewColor.CGColor
    }
    
    func setup() {
        scrubberBar = ScrubberBar(frame: CGRectMake(frame.origin.x, frame.size.height/4, frame.size.width, frame.size.height/2))
        scrubberElement.masterScrubber = self
    }
    
    func setupViews() {
        setTranslatesAutoresizingMaskIntoConstraints(false)
        addSubview(scrubberBar)
        addSubview(scrubberElement)
    }
    
    override public func intrinsicContentSize() -> CGSize {
        return CGSizeMake(100, 70)
    }
    
    override public class func requiresConstraintBasedLayout() -> Bool {
        return true
    }
    
    func setupLayout() {
        var constraintsArray = Array<NSObject>()
        
        // Background Bar Constraints
        constraintsArray.append(NSLayoutConstraint(item: scrubberBar, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0))
        constraintsArray.append(NSLayoutConstraint(item: scrubberBar, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0.0))
        constraintsArray.append(NSLayoutConstraint(item: scrubberBar, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Width, multiplier: 1.0, constant: 1.0))
        constraintsArray.append(NSLayoutConstraint(item: scrubberBar, attribute: NSLayoutAttribute.Height , relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 15))
        
        
        // Control Element Constraint
        let centerValue = scrubberBar.centerValueForItem(0)
        scrubberElementCenterConstraint = NSLayoutConstraint(item: scrubberElement, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: scrubberBar, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: centerValue)
        constraintsArray.append(scrubberElementCenterConstraint!)
        constraintsArray.append(NSLayoutConstraint(item: scrubberElement, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: scrubberBar, attribute: NSLayoutAttribute.Height, multiplier: 3.5, constant: 1.0))
        constraintsArray.append(NSLayoutConstraint(item: scrubberElement, attribute: NSLayoutAttribute.Width , relatedBy: NSLayoutRelation.Equal, toItem: scrubberBar, attribute: NSLayoutAttribute.Height, multiplier: 2.0, constant: 1.0))
        constraintsArray.append(NSLayoutConstraint(item: scrubberElement.scrubber, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: scrubberBar, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 1.0))
        
        self.addConstraints(constraintsArray)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        if let centerConstraint = scrubberElementCenterConstraint {
            centerConstraint.constant = scrubberBar.centerValueForItem(scrubberElement.index)
        }
        
        #if DEBUG
            checkLayoutForAmbiguity()
        #endif
    }
    
    func checkLayoutForAmbiguity() {
        if self.hasAmbiguousLayout() {
            println("WARNING - Ambiguous Layout in Coursera Scrubber Control")
        }
        
        if scrubberElement.hasAmbiguousLayout() {
            fatalError("ERROR - Ambiguous Layout in Scrubber Control!")
        }
        
        if scrubberBar.hasAmbiguousLayout() {
            fatalError("ERROR - Ambiguous Layout in Scrubber Bar!")
        }
    }
    
    //MARK: Public Methods
    
    /**
    Shows some example event items in the scrubber bar
    */
    public func showExampleEvents() {
        let defaultItemList = [
            ScrubberBarEventItem(index: 0.0),
            ScrubberBarEventItem(index: 0.3, color: UIColor.greenColor()),
            ScrubberBarEventItem(index: 0.5, color: UIColor.yellowColor(), completionClosure: {
                dispatch_async(dispatch_get_main_queue(), {
                    let alertView = UIAlertView(title: "Scrubber Event Fired", message: "Item fired at index 0.5" , delegate: nil, cancelButtonTitle: "Okay")
                    alertView.show()
                })
            }),
        ]
        scrubberBar.addEvents(defaultItemList)
    }
    
    /**
    Adds an event to the scrubber bar
    
    :param: value Index value to place the event
    :param: color Color of the event circle
    :param: completion Closure to execute once scruber reaches event index
    :warning: Only one event is allowed per index on the background bar
    */
    public func addEventAtValue(value: Float, color: UIColor, completion: ( () -> () )? = nil) {
        let newEventItem = ScrubberBarEventItem(index: value/duration, color: color, completion)
        
        // Shouldn't need to protect for mutability since this should all be on main thread
        scrubberBar.addEvent(newEventItem)
    }
    
    /**
    Removes event at index on scrubber if one exists
    
    :param: value Index of the event
    */
    public func removeEventAtValue(value: Float) {
        scrubberBar.removeEventAtIndex(value/duration)
    }
    
    /**
    :returns: All current events on scrubber bar
    */
    public func currentEvents() -> Array<ScrubberBarEventItem> {
        return scrubberBar.events()
    }
    
    //MARK: Control Element Gesture Handling
    
    func scrubberBeganDrag() {
        self.delegate?.scrubDidBegan()
    }
    
    func scrubberDidDragToPoint(dragPoint: CGPoint) {
        let sanitizedXCoord = scrubberBar.sanitizeCenterXCoord(dragPoint.x)
        scrubberElement.center = CGPointMake(sanitizedXCoord, scrubberElement.center.y)
        currentValue = scrubberBar.indexForCoord(sanitizedXCoord) * duration
        delegate?.didScrubToValue(currentValue)
    }
    
    func scrubberDidEndDragAtPoint(dragPoint: CGPoint) {
        scrubberElement.index = scrubberBar.indexForCoord(dragPoint.x)
        layoutSubviews()
        delegate?.scrubDidEnd()
    }
    
    //MARK: Event Item Handling
    
    func evaluateEventItems() {
        for event in scrubberBar.events() {
            if event.hasCompletionClosure && !event.didEventFire && event.index < scrubberElement.index {
                event.fire()
            }
        }
    }
    
}
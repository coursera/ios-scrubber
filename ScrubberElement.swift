//
//  ScrubberElement.swift
//  CourseraFoundation
//
//  Created by Brice Pollock on 9/11/14.
//  Copyright (c) 2014 Coursera. All rights reserved.
//

import UIKit

class ScrubberElement: UIView {
    
    private let labelHeight: CGFloat = 30
    private let scrubberHeight: CGFloat = 50
    private let elementWidth: CGFloat = 50
    private let verticalPadding: CGFloat = 5
    private var intrinsicHeight: CGFloat =  85 // kscrubberHeight + kVerticalPadding + kLabelHeight
    
    var timeLabel: UILabel
    var scrubber: UIView
    var index: Float = 0.0
    private var touchOverlay: UIView
    
    var elementColor: UIColor = UIColor.whiteColor() {
        didSet {
            scrubber.layer.backgroundColor = elementColor.CGColor
        }
    }
    
    weak var masterScrubber: ScrubberControl?
    
    //MARK: Fundamental Methods
    
    override init() {
        self.timeLabel = UILabel(frame: CGRectMake(0, 0, elementWidth, labelHeight))
        self.scrubber = UIView(frame: CGRectMake(0, labelHeight + verticalPadding, elementWidth, scrubberHeight))
        
        let thisFrame = CGRectMake(0, 0, elementWidth, intrinsicHeight)
        touchOverlay = UIView(frame: thisFrame)
        super.init(frame:thisFrame)
        
        setupView()
        setupConstraints()
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        self.init()
    }
    
    override func intrinsicContentSize() -> CGSize {
        return CGSizeMake(elementWidth, intrinsicHeight)
    }
    
    override class func requiresConstraintBasedLayout() -> Bool {
        return true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrubber.layer.cornerRadius = scrubber.frame.height/2
        
    }
    
    func setupView() {
        setTranslatesAutoresizingMaskIntoConstraints(false)
        timeLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        scrubber.setTranslatesAutoresizingMaskIntoConstraints(false)
        touchOverlay.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        scrubber.layer.backgroundColor = elementColor.CGColor
        
        timeLabel.text = "0:00"
        timeLabel.textColor = UIColor.whiteColor()
        timeLabel.textAlignment = NSTextAlignment.Center
        
        addSubview(timeLabel)
        addSubview(scrubber)
        addSubview(touchOverlay)
        
        touchOverlay.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "controlDragged:"))
    }
    
    func setupConstraints() {
        var constraintsArray = Array<NSObject>()
        // Control Element Constraints
        constraintsArray.append(NSLayoutConstraint(item: scrubber, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0))
        constraintsArray.append(NSLayoutConstraint(item: scrubber, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0.0))
        constraintsArray.append(NSLayoutConstraint(item: scrubber, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Width, multiplier: 1.0, constant: 1.0))
        constraintsArray.append(NSLayoutConstraint(item: scrubber, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Width, multiplier: 1.0, constant: 1.0))
        
        // Time Text Constraints
        constraintsArray.append(NSLayoutConstraint(item: timeLabel, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0))
        constraintsArray.append(NSLayoutConstraint(item: timeLabel, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0.0))
        constraintsArray.append(NSLayoutConstraint(item: timeLabel, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Width, multiplier: 2.0, constant: 1.0))
        constraintsArray.append(NSLayoutConstraint(item: timeLabel, attribute: NSLayoutAttribute.Baseline, relatedBy: NSLayoutRelation.Equal, toItem: scrubber, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: -verticalPadding))
        
        // Touch Overlay Constraints
        constraintsArray.append(NSLayoutConstraint(item: touchOverlay, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0))
        constraintsArray.append(NSLayoutConstraint(item: touchOverlay, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0.0))
        constraintsArray.append(NSLayoutConstraint(item: touchOverlay, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Width, multiplier: 1.0, constant: 1.0))
        constraintsArray.append(NSLayoutConstraint(item: touchOverlay, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Height, multiplier: 1.0, constant: 1.0))
        
        addConstraints(constraintsArray)
    }
    
    //MARK: Gesture Handling
    
    func controlDragged(gestureRecognizer: UIPanGestureRecognizer) {
        if let validParent = masterScrubber {
            switch gestureRecognizer.state {
            case UIGestureRecognizerState.Began:
                validParent.scrubberBeganDrag()
            case UIGestureRecognizerState.Changed:
                validParent.scrubberDidDragToPoint(gestureRecognizer.locationInView(validParent))
            case UIGestureRecognizerState.Ended:
                validParent.scrubberDidEndDragAtPoint(gestureRecognizer.locationInView(validParent))
            default:
                // Do nothing
                return
            }
        }
    }
}
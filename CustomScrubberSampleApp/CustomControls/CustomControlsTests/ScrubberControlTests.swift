//
//  ScrubberControlTests.swift
//  CustomControls
//
//  Created by Brice Pollock on 9/16/14.
//  Copyright (c) 2014 Coursera. All rights reserved.
//

import Foundation
import UIKit
import XCTest
import CustomControls

class ScrubberControlTests: XCTestCase {
    
    var scrubber: ScrubberControl!
    
    override func setUp() {
        super.setUp()
        scrubber = ScrubberControl(frame: CGRectMake(0, 0, 100, 70))
        for event in scrubber.scrubberBar.events() {
            scrubber.scrubberBar.removeEventAtIndex(event.index)
        }
        
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // Tests event item init method and our scrubber add/remove API
    func testScrubberBarEventItems() {
        XCTAssertEqual(scrubber.scrubberBar.events().count, 0, "Unable to remove events on setup")
        
        // Add events at bad indexes
        scrubber.addEventAtValue(-10, color: UIColor.clearColor())
        XCTAssertEqual(scrubber.scrubberBar.events().count, 1, "Event not added")
        XCTAssertEqual(scrubber.scrubberBar.events()[0].index, 0, "Event did not handle negative index")
        
        scrubber.removeEventAtValue(0)
        XCTAssertEqual(scrubber.scrubberBar.events().count, 0, "Unable to remove event")
        
        XCTAssertEqual(scrubber.scrubberBar.events().count, 0, "Should start at zero events")
        scrubber.addEventAtValue(12345, color: UIColor.clearColor())
        XCTAssertEqual(scrubber.scrubberBar.events().count, 1, "Event not added")
        XCTAssertEqual(scrubber.scrubberBar.events()[0].index, 1, "Event did not handle overflow of maximum index")
        
        // clean up after ourself
        scrubber.removeEventAtValue(1)
        XCTAssertEqual(scrubber.scrubberBar.events().count, 0, "Unable to remove event")
        
        // Add two events on top of eachother
        scrubber.addEventAtValue(0.20, color: UIColor.clearColor())
        scrubber.addEventAtValue(0.20, color: UIColor.whiteColor())
        XCTAssertEqual(scrubber.scrubberBar.events().count, 1, "Events at same index did not overwrite eachother")
        XCTAssertEqual(scrubber.scrubberBar.events()[0].color, UIColor.whiteColor(), "First event overwrote first one!")
    }
    
    func testScrubberBar_centerValue() {
        
        // Hard to Test Valid Values
        XCTAssertEqual(scrubber.scrubberBar.centerValueForItem(0), 0, "Did not pass valid test for index: 0")
        XCTAssertEqual(scrubber.scrubberBar.centerValueForItem(1), 100, "Did not pass valid test for index: 1")
        XCTAssertEqual(Int(scrubber.scrubberBar.centerValueForItem(0.3)), 30, "Did not pass balid test for index: 0.3")
        
        // Test Invalid Values
        XCTAssertEqual(scrubber.scrubberBar.centerValueForItem(-10), 0, "Did not pass invalid test for index: -10")
        XCTAssertEqual(scrubber.scrubberBar.centerValueForItem(10), 0, "Did not pass invalid test for index: 10")
        
    }
    
    func testScrubberBar_sanitizeCenter() {
        //TODO: Needs to correctly test for these cases
        
        // Test Valid Values
        var result = scrubber.scrubberBar.sanitizeCenterXCoord(30)
        XCTAssertEqual(result, 30)
        
        // Test Invalid Values
        result = scrubber.scrubberBar.sanitizeCenterXCoord(0)
        XCTAssertEqual(result, 0)
        
        result = scrubber.scrubberBar.sanitizeCenterXCoord(-30)
        XCTAssertEqual(result, 0)
        
        result = scrubber.scrubberBar.sanitizeCenterXCoord(123456)
        XCTAssertEqual(result, 100)
        
    }
    
    func testScrubberBar_indexForCoord() {
        //TODO: Need to add tests for this method
    }
}

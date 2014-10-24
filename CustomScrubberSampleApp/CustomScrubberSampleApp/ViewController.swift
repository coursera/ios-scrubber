//
//  ViewController.swift
//  CustomScrubberSampleApp
//
//  Created by Brice Pollock on 10/17/14.
//  Copyright (c) 2014 Coursera. All rights reserved.
//

import UIKit
import CustomControls

class ViewController: UIViewController, ScrubberControlEventsDelegate {
    
    @IBOutlet weak var scrubber: ScrubberControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        let currentValue: Float = 25
        let duration: Float = 5 * 60 + 23
        
        scrubber.showExampleEvents()
        scrubber.minimumValue = 0
        scrubber.maximumValue = duration
        scrubber.currentValue = currentValue
        scrubber.valueLabel?.text = formatTimeAsString(Double(currentValue))
        scrubber.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: Coursera Scrubber Delegate
    
    func scrubDidBegan() {
    }
    
    func didScrubToValue(value: Float) {
        scrubber.valueLabel?.text = formatTimeAsString(Double(value))
    }
    
    func scrubDidEnd() {
    }

    // Helper Methods
    
    func formatTimeAsString(timeSeconds: Double, showHours: Bool = false) -> String {
        var positiveTimeSeconds = timeSeconds
        var formattedString: String = ""
        if timeSeconds < 0 {
            positiveTimeSeconds = -positiveTimeSeconds
            formattedString = "-"
        }
        
        let hours = Int(positiveTimeSeconds / 3600)
        let minutes = Int((positiveTimeSeconds / 60) % 60)
        let seconds = Int(positiveTimeSeconds % 60)
        if (hours == 0 && minutes == 0) || (hours == 0 && !showHours) {
            formattedString += NSString(format: "%u:%02u", minutes, seconds)
        } else {
            formattedString += NSString(format: "%u:%02u:%02u", hours, minutes, seconds)
        }
        return formattedString
    }
}


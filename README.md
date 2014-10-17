# Custom iOS Scrubber Control
![ScrubberControl Image](/readme_images/scrubberControlImage.jpg?raw=true)

## Technical Requirements
* This control requires autolayout and iOS 8
* Control currently only works with Swift, but could easily be augmented for obj-c using the @objc attribute

## Features
* Drop in support into Storyboard with Custom Attributes for component coloring or via frame initialization
* Autolayout should handle size class changes automatically
* Buffer fill bar to indicate amount of an item (Ex: video) has been downloaded
* Dynamic scrubber element responds to user drag gestures
* Ability to add events on the ScrubberBar which can execute closures when scrubber element surpasses their index

## Known Issues
* Control supports Live Rendering in Storyboard, however the Designable feature in Xcode 'Times Out' when loaded the custom view
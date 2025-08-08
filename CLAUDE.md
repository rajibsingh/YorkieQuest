# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

YorkieQuest is an iOS SwiftUI application built with Xcode 16.4. The project targets iOS 18.5+ and uses Swift 5.0. It's a SpriteKit-based game where a Yorkie dog runs to where the user touches the screen, featuring animated sprite-based movement with different walking and running animations.

## Build and Development Commands

### Building the App
```bash
# Build the project (from project root)
xcodebuild -project YorkieQuest.xcodeproj -scheme YorkieQuest -destination 'platform=iOS Simulator,name=iPhone 16' build

# Build for device
xcodebuild -project YorkieQuest.xcodeproj -scheme YorkieQuest -destination 'generic/platform=iOS' build
```

### Running Tests
```bash
# Run unit tests
xcodebuild -project YorkieQuest.xcodeproj -scheme YorkieQuest -destination 'platform=iOS Simulator,name=iPhone 16' test -only-testing:YorkieQuestTests

# Run UI tests
xcodebuild -project YorkieQuest.xcodeproj -scheme YorkieQuest -destination 'platform=iOS Simulator,name=iPhone 16' test -only-testing:YorkieQuestUITests

# Run all tests
xcodebuild -project YorkieQuest.xcodeproj -scheme YorkieQuest -destination 'platform=iOS Simulator,name=iPhone 16' test
```

### Archive for Distribution
```bash
# Create archive for App Store distribution
xcodebuild -project YorkieQuest.xcodeproj -scheme YorkieQuest -destination 'generic/platform=iOS' archive -archivePath YorkieQuest.xcarchive
```

## Project Structure

- **YorkieQuest/**: Main application source code
  - `YorkieQuestApp.swift`: App entry point using `@main` attribute
  - `ContentView.swift`: SwiftUI view that displays the SpriteKit game scene
  - `YorkieGameScene.swift`: Main SpriteKit game scene with Yorkie sprite and touch-to-move logic
  - `Assets.xcassets/`: Image and color assets, including yorkie sprite sheet
- **YorkieQuestTests/**: Unit tests using Swift Testing framework
- **YorkieQuestUITests/**: UI tests for user interface validation
- **YorkieQuest.xcodeproj/**: Xcode project configuration

## Architecture Notes

- **Framework**: SwiftUI + SpriteKit hybrid architecture
- **Game Engine**: Uses SpriteKit (`YorkieGameScene`) for 2D game logic and sprite animation
- **UI Integration**: SwiftUI `ContentView` hosts the SpriteKit scene via `SpriteView`
- **Testing**: Uses Swift Testing framework (not XCTest) - note the `import Testing` and `@Test` attributes
- **Deployment**: Targets iOS 18.5+ with development team ID 9J9T6457HV
- **Bundle ID**: com.sepoysoftware.YorkieQuest
- **Asset Management**: Uses Xcode asset catalogs with sprite sheet texture extraction

## Game Mechanics

- **Touch-to-Move**: Tap anywhere on screen to make the Yorkie move to that location
- **Distance-Based Animation**: Short distances trigger walking animations, long distances (>150 points) trigger running
- **Directional Animation**: Yorkie faces correct direction with appropriate sprite animations
- **Idle Behavior**: After 10 seconds of inactivity, Yorkie starts snoozing animation
- **Sprite System**: Uses texture atlas extraction from a single sprite sheet

## Sprite Sheet Animation Mapping

The game uses a sprite sheet (`yorkie.png`) with the following row/frame mappings:

- **Walk Up**: Row 2, Frames 0-3 (4 frames)
- **Walk Down**: Row 0, Frames 0-3 (4 frames)  
- **Walk Right**: Row 1, Frames 0-3 (4 frames)
- **Walk Left**: Row 1, Frames 0-3 (4 frames, horizontally flipped)
- **Idle**: Row 4, Frames 0-3 (4 frames)
- **Snooze**: Row 7, Frames 0-1 (2 frames)
- **Run Right**: Row 8, Frames 0-2 (3 frames)
- **Run Left**: Row 9, Frames 0-2 (3 frames)

## Development Notes

- The project uses SwiftUI previews (`#Preview`) for development
- Sprite sheet texture extraction uses dynamic sizing based on 4-column layout
- Project follows standard iOS app conventions with automatic code signing
- When adding new Swift files, ensure they're added to the appropriate target in Xcode project settings
- Debug logging is available for sprite dimensions and extraction coordinates
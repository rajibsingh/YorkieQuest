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

### Controls
- **Touch Controls**: Tap anywhere on screen to make the Yorkie move to that location
- **Keyboard Controls**: Use arrow keys (↑↓←→) to control the Yorkie with continuous movement
  - **Cross-Platform Support**: Works on macOS (via `NSEvent`) and iOS/iPadOS with external keyboards (via `UIPress`)
  - **iPad Compatibility**: Full support for external keyboards on iPad (Magic Keyboard, Smart Keyboard, Bluetooth keyboards)
  - **Continuous Movement**: Smooth, responsive movement at 150 points/second while keys are held
  - **Multi-Key Support**: Diagonal movement when multiple keys are pressed (e.g., Up+Right)

### Gameplay Features
- **Distance-Based Animation**: Short distances trigger walking animations, long distances (>150 points) trigger running
- **Directional Animation**: Yorkie faces correct direction with appropriate sprite animations
- **Idle Behavior**: After 10 seconds of inactivity, Yorkie starts snoozing animation
- **Sprite System**: Uses texture atlas extraction from a single sprite sheet with bounds checking and nearest-neighbor filtering

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

## Technical Implementation

### Input System
- **Dual Input Architecture**: Touch and keyboard controls work simultaneously without conflicts
- **Platform-Specific Handling**: 
  - macOS: `keyDown`/`keyUp` with `NSEvent` for desktop keyboard input
  - iOS/iPadOS: `pressesBegan`/`pressesEnded` with `UIPress` for external keyboard support
- **State Management**: Uses `Set<String>` to track currently pressed keys for multi-key combinations
- **Movement Integration**: Keyboard input overrides touch movement; touch input temporarily disables keyboard movement

### Sprite Rendering Improvements
- **Texture Extraction**: Enhanced bounds checking prevents texture clipping during sprite sheet extraction
- **Filtering Mode**: Uses `.nearest` filtering to maintain pixel-perfect sprite rendering
- **Anchor Point**: Centered anchor point (0.5, 0.5) prevents sprite clipping during animations
- **Scale Handling**: Consistent scale management prevents visual artifacts during horizontal flipping

### Performance Optimizations
- **60 FPS Movement**: Keyboard movement updates in the main game loop at target framerate
- **Boundary Checking**: Efficient screen boundary clamping keeps Yorkie within visible area
- **Animation Caching**: Texture arrays cached per animation type for smooth sprite transitions

## Development Notes

- The project uses SwiftUI previews (`#Preview`) for development
- Sprite sheet texture extraction uses dynamic sizing based on 4-column layout with enhanced bounds checking
- Project follows standard iOS app conventions with automatic code signing
- When adding new Swift files, ensure they're added to the appropriate target in Xcode project settings
- Keyboard controls require external keyboards for iOS/iPadOS testing
- Debug logging is available for sprite dimensions and extraction coordinates
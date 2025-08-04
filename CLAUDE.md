# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

YorkieQuest is an iOS SwiftUI application built with Xcode 16.4. The project targets iOS 18.5+ and uses Swift 5.0. It's a standard iOS app project with unit tests and UI tests.

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
  - `ContentView.swift`: Main SwiftUI view (currently displays "Hello, world!")
  - `Assets.xcassets/`: Image and color assets, including custom yorkie image
- **YorkieQuestTests/**: Unit tests using Swift Testing framework
- **YorkieQuestUITests/**: UI tests for user interface validation
- **YorkieQuest.xcodeproj/**: Xcode project configuration

## Architecture Notes

- **Framework**: SwiftUI with standard iOS app lifecycle
- **Testing**: Uses Swift Testing framework (not XCTest) - note the `import Testing` and `@Test` attributes
- **Deployment**: Targets iOS 18.5+ with development team ID 9J9T6457HV
- **Bundle ID**: com.sepoysoftware.YorkieQuest
- **Asset Management**: Uses Xcode asset catalogs for images and colors

## Development Notes

- The project uses SwiftUI previews (`#Preview`) for development
- Custom yorkie image asset is available in the asset catalog
- Project follows standard iOS app conventions with automatic code signing
- When adding new Swift files, ensure they're added to the appropriate target in Xcode project settings
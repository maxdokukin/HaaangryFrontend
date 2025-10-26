# Haaangry Frontend

iOS app for discovering restaurants when you're feeling "haaangry" (hangry + angry).

## Requirements

- macOS with Xcode 14.0 or later
- iOS 16.0+ deployment target
- Swift 5.7+

## Quick Start

1. **Open the project in Xcode:**
   ```bash
   open HaaangryFrontend.xcodeproj
   ```

2. **Select a simulator or device:**
   - Click the device selector in the toolbar
   - Choose an iPhone simulator or connected device

3. **Build and run:**
   - Press `Cmd + R` or click the Play button
   - The app will compile and launch on your selected device

## Project Structure

```
HaaangryFrontend/
├── HaaangryFrontendApp.swift  # App entry point
├── ContentView.swift            # Main view
├── Models/                      # Data models
├── Views/                       # UI components
├── Networking/                  # API client
├── Stores/                      # State management
├── Utilities/                   # Helper functions
├── Overlays/                    # UI overlays
└── Resources/                   # Assets and resources
```

## Configuration

Make sure the backend API URL is configured correctly in the networking layer to point to your running backend instance (default: `http://localhost:8000`).

## Troubleshooting

- **Build fails:** Clean the build folder with `Cmd + Shift + K` and rebuild
- **Simulator issues:** Reset the simulator from `Device > Erase All Content and Settings`
- **Code signing:** Select your development team in the project settings under `Signing & Capabilities`

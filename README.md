# GeoFencingSDK (iOS)

A lightweight **Swift Package** that monitors iOS geofences and notifies your app when a geofence is hit. It can also **best-effort** POST geofence events to your webhook endpoint.

## What you get

- **Geofence monitoring** via `CLLocationManager` + `CLCircularRegion`
- **In-app callbacks** via `NotificationCenter`
- **Best-effort webhook** POST for enter/exit events (no auth, no offline retry)

## iOS limitations (important)

- iOS monitors **up to 20 regions per app**.
- If the user **force-quits** (swipes away) your app, iOS generally **will not relaunch** it for geofence events until the user opens it again.
- To receive events reliably in the background, your app must request **Always** location authorization and enable the proper background mode.

## Installation (SPM)

Add this package to your app using Xcode:

- File → Add Packages… → select this repository / local path
- Import `GeoFencingSDK` in your app code

## Host app setup

### Capabilities

In Xcode → Signing & Capabilities:

- Background Modes → enable **Location updates**

### Info.plist

Add usage descriptions:

- `NSLocationWhenInUseUsageDescription`
- `NSLocationAlwaysAndWhenInUseUsageDescription`
- `NSLocationAlwaysUsageDescription` (only if you support older iOS versions)

### Permissions (recommended flow)

Request When-In-Use first, then Always (Apple guidance). The SDK does not force prompts for you.

## Usage

Initialize early (important for relaunch/terminated delivery):

```swift
import GeoFencingSDK

// AppDelegate didFinishLaunching / early app startup
GeoFencingSDK.bootstrap()

GeoFencingSDK.shared.configure(
    options: GeoFencingOptions(
        webhookURL: URL(string: "https://your-domain.com/geofence/events"),
        enableDebugLogs: true
    )
)
```

Start monitoring regions:

```swift
import GeoFencingSDK

let regions: [GeoFenceRegion] = [
    .init(id: "office",
          latitude: 37.3317,
          longitude: -122.0301,
          radiusMeters: 150,
          notifyOnEntry: true,
          notifyOnExit: true)
]

try GeoFencingSDK.shared.startMonitoring(regions: regions)
```

Listen for events using NotificationCenter:

```swift
import GeoFencingSDK

let enterObs = NotificationCenter.default.addObserver(
    forName: .geoFenceDidEnter,
    object: nil,
    queue: .main
) { note in
    if let event = note.userInfo?[GeoFencingNotificationUserInfoKey.event] as? GeoFenceEvent {
        print("ENTER:", event.regionId, event.timestamp)
    }
}

let exitObs = NotificationCenter.default.addObserver(
    forName: .geoFenceDidExit,
    object: nil,
    queue: .main
) { note in
    if let event = note.userInfo?[GeoFencingNotificationUserInfoKey.event] as? GeoFenceEvent {
        print("EXIT:", event.regionId, event.timestamp)
    }
}
```

Stop monitoring:

```swift
GeoFencingSDK.shared.stopMonitoring(ids: ["office"])
// or
GeoFencingSDK.shared.stopAll()
```

## Webhook payload

If `webhookURL` is set, the SDK sends a JSON body (ISO-8601 timestamp) similar to:

```json
{
  "regionId": "office",
  "transition": "enter",
  "timestamp": "1970-01-01T00:00:00Z",
  "regionLatitude": 37.3317,
  "regionLongitude": -122.0301,
  "regionRadiusMeters": 150,
  "appState": "background"
}
```

Notes:

- No authentication headers (as requested)
- **Best-effort only**: if iOS doesn’t allow enough background time or the network is unavailable, the event may be dropped



import Foundation

/// Public facade for configuring and using region monitoring via CoreLocation.
///
/// Important:
/// - Region events can be delivered while your app is not running, if iOS relaunches the app in the background.
/// - If the user force-quits the app, iOS generally will not relaunch it for region events until the user opens it again.
@MainActor
public final class GeoFencingSDK {
    public static let shared = GeoFencingSDK()

    private let manager: GeoFenceManager

    private init() {
        self.manager = GeoFenceManager()
    }

    /// Call this early (e.g. app launch) to ensure the SDK is initialized and ready to receive region callbacks.
    public static func bootstrap() {
        _ = GeoFencingSDK.shared
    }

    /// Configure SDK behavior.
    public func configure(options: GeoFencingOptions) {
        manager.configure(options: options)
    }

    /// Start monitoring the provided regions. iOS enforces a maximum of 20 monitored regions per app.
    public func startMonitoring(regions: [GeoFenceRegion]) throws {
        try manager.startMonitoring(regions: regions)
    }

    /// Stop monitoring the given region identifiers.
    public func stopMonitoring(ids: [String]) {
        manager.stopMonitoring(ids: ids)
    }

    /// Stop monitoring all regions currently monitored by CoreLocation.
    public func stopAll() {
        manager.stopAll()
    }

    /// Returns the currently monitored region identifiers (as reported by CoreLocation).
    public func currentMonitoredRegionIDs() -> [String] {
        manager.currentMonitoredRegionIDs()
    }
}



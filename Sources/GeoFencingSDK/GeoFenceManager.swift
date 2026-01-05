import CoreLocation
import Foundation

@MainActor
final class GeoFenceManager: NSObject {
    private let dispatcher: GeoFenceEventDispatcher
    private let locationManager: CLLocationManager
    private var enableDebugLogs: Bool = false

    override init() {
        self.locationManager = CLLocationManager()
        self.dispatcher = GeoFenceEventDispatcher()
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self.locationManager.distanceFilter = kCLDistanceFilterNone
        if #available(iOS 9.0, macOS 10.15, *) {
            self.locationManager.allowsBackgroundLocationUpdates = true
        }
    }

    func configure(options: GeoFencingOptions) {
        self.enableDebugLogs = options.enableDebugLogs
        dispatcher.configure(options: options)
    }

    func startMonitoring(regions: [GeoFenceRegion]) throws {
        let maxAllowed = 20
        guard regions.count <= maxAllowed else {
            throw GeoFencingError.tooManyRegions(maxAllowed: maxAllowed)
        }

        // Stop regions that are no longer desired.
        let desired = Set(regions.map(\.id))
        for region in locationManager.monitoredRegions where !desired.contains(region.identifier) {
            locationManager.stopMonitoring(for: region)
        }

        // Start (or re-start) requested regions.
        for region in regions {
            let clRegion = try region.toCLRegion()
            locationManager.startMonitoring(for: clRegion)
        }

        debugLog("monitoring \(locationManager.monitoredRegions.count) regions")
    }

    func stopMonitoring(ids: [String]) {
        let idsSet = Set(ids)
        for region in locationManager.monitoredRegions where idsSet.contains(region.identifier) {
            locationManager.stopMonitoring(for: region)
        }
    }

    func stopAll() {
        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: region)
        }
    }

    func currentMonitoredRegionIDs() -> [String] {
        locationManager.monitoredRegions.map(\.identifier).sorted()
    }

    func processRegionEvent(transition: GeoFenceTransition, region: CLRegion) {
        dispatcher.dispatch(transition: transition, region: region)
    }

    private func debugLog(_ message: String) {
        guard enableDebugLogs else { return }
        print("[GeoFencingSDK] \(message)")
    }
}

extension GeoFenceManager: @preconcurrency CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        debugLog("didEnterRegion: \(region.identifier)")
        processRegionEvent(transition: .enter, region: region)
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        debugLog("didExitRegion: \(region.identifier)")
        processRegionEvent(transition: .exit, region: region)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        debugLog("didFailWithError: \(error)")
    }

    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        debugLog("monitoringDidFailFor region=\(region?.identifier ?? "nil"): \(error)")
    }
}



import CoreLocation
import Foundation

#if canImport(UIKit)
import UIKit
#endif

@MainActor
final class GeoFenceEventDispatcher {
    private var options: GeoFencingOptions
    private let webhookClient: WebhookClient
    private var eventSink: ((GeoFenceEvent) -> Void)?

    init(options: GeoFencingOptions = GeoFencingOptions(), webhookClient: WebhookClient = WebhookClient()) {
        self.options = options
        self.webhookClient = webhookClient
    }

    func configure(options: GeoFencingOptions) {
        self.options = options
    }

    func setEventSink(_ sink: ((GeoFenceEvent) -> Void)?) {
        self.eventSink = sink
    }

    func dispatch(transition: GeoFenceTransition, region: CLRegion) {
        let (lat, lon, radius): (Double?, Double?, Double?) = {
            guard let circular = region as? CLCircularRegion else { return (nil, nil, nil) }
            return (circular.center.latitude, circular.center.longitude, circular.radius)
        }()

        let event = GeoFenceEvent(
            regionId: region.identifier,
            transition: transition,
            timestamp: Date(),
            regionLatitude: lat,
            regionLongitude: lon,
            regionRadiusMeters: radius,
            appState: currentAppState()
        )

        eventSink?(event)

        let name: Notification.Name = (transition == .enter) ? .geoFenceDidEnter : .geoFenceDidExit
        options.notificationCenter.post(
            name: name,
            object: event,
            userInfo: [GeoFencingNotificationUserInfoKey.event: event]
        )

        if let url = options.webhookURL {
            webhookClient.postEvent(event, to: url, debugLogs: options.enableDebugLogs)
        }
    }

    private func debugLog(_ message: String) {
        guard options.enableDebugLogs else { return }
        print("[GeoFencingSDK] \(message)")
    }

    private func currentAppState() -> String? {
#if canImport(UIKit)
        // Avoid using UIApplication in app extensions.
        if Bundle.main.bundlePath.hasSuffix(".appex") { return nil }
        switch UIApplication.shared.applicationState {
        case .active: return "active"
        case .inactive: return "inactive"
        case .background: return "background"
        @unknown default: return "unknown"
        }
#else
        return nil
#endif
    }
}



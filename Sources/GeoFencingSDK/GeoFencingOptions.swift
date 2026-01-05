import Foundation

public struct GeoFencingOptions: Sendable {
    /// Optional webhook URL; when set, the SDK will best-effort POST geofence events.
    public var webhookURL: URL?

    /// NotificationCenter used for event delivery. Defaults to `.default`.
    public var notificationCenter: NotificationCenter

    /// Enables internal debug logging (printed to stdout).
    public var enableDebugLogs: Bool

    public init(
        webhookURL: URL? = nil,
        notificationCenter: NotificationCenter = .default,
        enableDebugLogs: Bool = false
    ) {
        self.webhookURL = webhookURL
        self.notificationCenter = notificationCenter
        self.enableDebugLogs = enableDebugLogs
    }
}



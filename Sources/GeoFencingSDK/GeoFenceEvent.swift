import Foundation

public enum GeoFenceTransition: String, Sendable, Codable {
    case enter
    case exit
}

public struct GeoFenceEvent: Sendable, Codable, Equatable {
    public var regionId: String
    public var transition: GeoFenceTransition
    public var timestamp: Date

    /// Region center (not the user’s precise location).
    public var regionLatitude: Double?
    public var regionLongitude: Double?
    public var regionRadiusMeters: Double?

    /// Best-effort app state at delivery time, for diagnostics.
    public var appState: String?

    public init(
        regionId: String,
        transition: GeoFenceTransition,
        timestamp: Date = Date(),
        regionLatitude: Double? = nil,
        regionLongitude: Double? = nil,
        regionRadiusMeters: Double? = nil,
        appState: String? = nil
    ) {
        self.regionId = regionId
        self.transition = transition
        self.timestamp = timestamp
        self.regionLatitude = regionLatitude
        self.regionLongitude = regionLongitude
        self.regionRadiusMeters = regionRadiusMeters
        self.appState = appState
    }
}



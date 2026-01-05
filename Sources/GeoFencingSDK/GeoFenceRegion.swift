import CoreLocation
import Foundation

public struct GeoFenceRegion: Sendable, Hashable, Codable {
    public var id: String
    public var latitude: Double
    public var longitude: Double
    public var radiusMeters: Double
    public var notifyOnEntry: Bool
    public var notifyOnExit: Bool

    public init(
        id: String,
        latitude: Double,
        longitude: Double,
        radiusMeters: Double,
        notifyOnEntry: Bool = true,
        notifyOnExit: Bool = true
    ) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.radiusMeters = radiusMeters
        self.notifyOnEntry = notifyOnEntry
        self.notifyOnExit = notifyOnExit
    }

    internal func toCLRegion() throws -> CLCircularRegion {
        guard radiusMeters > 0 else {
            throw GeoFencingError.invalidRadius
        }
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = CLCircularRegion(center: center, radius: radiusMeters, identifier: id)
        region.notifyOnEntry = notifyOnEntry
        region.notifyOnExit = notifyOnExit
        return region
    }
}



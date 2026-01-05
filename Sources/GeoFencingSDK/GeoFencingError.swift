import Foundation

public enum GeoFencingError: Error, Equatable {
    case tooManyRegions(maxAllowed: Int)
    case invalidRadius
}



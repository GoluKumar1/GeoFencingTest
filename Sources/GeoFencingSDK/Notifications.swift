import Foundation

public extension Notification.Name {
    static let geoFenceDidEnter = Notification.Name("GeoFencingSDK.geoFenceDidEnter")
    static let geoFenceDidExit = Notification.Name("GeoFencingSDK.geoFenceDidExit")
}

public enum GeoFencingNotificationUserInfoKey {
    public static let event = "GeoFencingSDK.event"
}



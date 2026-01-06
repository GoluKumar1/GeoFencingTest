import Foundation

public protocol GeoFencingSDKDelegate: AnyObject {
    /// Called when iOS reports the device entered a monitored region.
    func geoFencingSDK(_ sdk: GeoFencingSDK, didEnter event: GeoFenceEvent)

    /// Called when iOS reports the device exited a monitored region.
    func geoFencingSDK(_ sdk: GeoFencingSDK, didExit event: GeoFenceEvent)
}

public extension GeoFencingSDKDelegate {
    func geoFencingSDK(_ sdk: GeoFencingSDK, didExit event: GeoFenceEvent) {}
}



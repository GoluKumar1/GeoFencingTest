import CoreLocation
import XCTest
@testable import GeoFencingSDK

final class GeoFencingSDKTests: XCTestCase {
    func testGeoFenceEventEncoding_iso8601() throws {
        let event = GeoFenceEvent(
            regionId: "r1",
            transition: .enter,
            timestamp: Date(timeIntervalSince1970: 0),
            regionLatitude: 1,
            regionLongitude: 2,
            regionRadiusMeters: 100,
            appState: "background"
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(event)

        XCTAssertFalse(data.isEmpty)
    }

    func testNotificationPostedOnEnterRegion() async {
        let nc = NotificationCenter()
        let exp = expectation(description: "enter notification")

        let observer = nc.addObserver(forName: .geoFenceDidEnter, object: nil, queue: nil) { note in
            guard let event = note.userInfo?[GeoFencingNotificationUserInfoKey.event] as? GeoFenceEvent else {
                XCTFail("missing GeoFenceEvent in userInfo")
                return
            }
            XCTAssertEqual(event.regionId, "office")
            XCTAssertEqual(event.transition, .enter)
            exp.fulfill()
        }
        defer { nc.removeObserver(observer) }

        await MainActor.run {
            let dispatcher = GeoFenceEventDispatcher(options: GeoFencingOptions(notificationCenter: nc))

            let region = CLCircularRegion(
                center: CLLocationCoordinate2D(latitude: 37.0, longitude: -122.0),
                radius: 100,
                identifier: "office"
            )
            dispatcher.dispatch(transition: .enter, region: region)
        }

        await fulfillment(of: [exp], timeout: 1.0)
    }

    func testNotificationPostedOnExitRegion() async {
        let nc = NotificationCenter()
        let exp = expectation(description: "exit notification")

        let observer = nc.addObserver(forName: .geoFenceDidExit, object: nil, queue: nil) { note in
            guard let event = note.userInfo?[GeoFencingNotificationUserInfoKey.event] as? GeoFenceEvent else {
                XCTFail("missing GeoFenceEvent in userInfo")
                return
            }
            XCTAssertEqual(event.regionId, "office")
            XCTAssertEqual(event.transition, .exit)
            exp.fulfill()
        }
        defer { nc.removeObserver(observer) }

        await MainActor.run {
            let dispatcher = GeoFenceEventDispatcher(options: GeoFencingOptions(notificationCenter: nc))

            let region = CLCircularRegion(
                center: CLLocationCoordinate2D(latitude: 37.0, longitude: -122.0),
                radius: 100,
                identifier: "office"
            )
            dispatcher.dispatch(transition: .exit, region: region)
        }

        await fulfillment(of: [exp], timeout: 1.0)
    }

    func testEventSinkCalledOnEnterAndExit() async {
        let expEnter = expectation(description: "eventSink enter")
        let expExit = expectation(description: "eventSink exit")

        await MainActor.run {
            let dispatcher = GeoFenceEventDispatcher()
            dispatcher.setEventSink { event in
                if event.transition == .enter {
                    expEnter.fulfill()
                } else {
                    expExit.fulfill()
                }
            }

            let region = CLCircularRegion(
                center: CLLocationCoordinate2D(latitude: 37.0, longitude: -122.0),
                radius: 100,
                identifier: "office"
            )
            dispatcher.dispatch(transition: .enter, region: region)
            dispatcher.dispatch(transition: .exit, region: region)
        }

        await fulfillment(of: [expEnter, expExit], timeout: 1.0)
    }
}



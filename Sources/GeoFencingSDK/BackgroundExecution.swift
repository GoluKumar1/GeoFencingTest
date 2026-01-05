import Foundation

#if canImport(UIKit)
import UIKit
#endif

enum BackgroundExecution {
    /// Returns a closure to end the background task (or a no-op on unsupported platforms).
    static func begin(debugLogs: Bool) -> () -> Void {
#if canImport(UIKit)
        // Avoid using UIApplication in app extensions.
        let isAppExtension = Bundle.main.bundlePath.hasSuffix(".appex")
        if isAppExtension {
            return {}
        }

        let application = UIApplication.shared
        var taskId: UIBackgroundTaskIdentifier = .invalid
        taskId = application.beginBackgroundTask(withName: "GeoFencingSDK.Webhook") {
            if debugLogs {
                print("[GeoFencingSDK] background task expired")
            }
            if taskId != .invalid {
                application.endBackgroundTask(taskId)
                taskId = .invalid
            }
        }

        return {
            if taskId != .invalid {
                application.endBackgroundTask(taskId)
                taskId = .invalid
            }
        }
#else
        return {}
#endif
    }
}




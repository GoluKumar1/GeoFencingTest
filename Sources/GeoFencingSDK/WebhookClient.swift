import Foundation

final class WebhookClient: @unchecked Sendable {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func postEvent(_ event: GeoFenceEvent, to url: URL, debugLogs: Bool) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        do {
            request.httpBody = try encoder.encode(event)
        } catch {
            if debugLogs {
                print("[GeoFencingSDK] webhook encode failed: \(error)")
            }
            return
        }

        let endBackgroundTask = BackgroundExecution.begin(debugLogs: debugLogs)
        let task = self.session.dataTask(with: request) { _, response, error in
            defer { endBackgroundTask() }
            if debugLogs {
                if let error {
                    print("[GeoFencingSDK] webhook POST failed: \(error)")
                } else if let http = response as? HTTPURLResponse {
                    print("[GeoFencingSDK] webhook POST status: \(http.statusCode)")
                } else {
                    print("[GeoFencingSDK] webhook POST done")
                }
            }
        }
        task.resume()
    }
}



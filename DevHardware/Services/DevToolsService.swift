import Foundation
import CryptoKit

enum DevToolsService {
    static func formatJSON(_ text: String) -> Result<String, Error> {
        do {
            let object = try JSONSerialization.jsonObject(with: Data(text.utf8), options: [.fragmentsAllowed])
            let data = try JSONSerialization.data(
                withJSONObject: object,
                options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes, .fragmentsAllowed]
            )
            return .success(String(decoding: data, as: UTF8.self))
        } catch {
            return .failure(error)
        }
    }

    static func decodeJWT(_ token: String) -> (header: String, payload: String)? {
        let parts = token.trimmingCharacters(in: .whitespacesAndNewlines).split(separator: ".", omittingEmptySubsequences: false)
        guard parts.count == 3,
              let header = decodeSegment(String(parts[0])),
              let payload = decodeSegment(String(parts[1])) else { return nil }
        return (header, payload)
    }

    static func sha256(_ text: String) -> String {
        SHA256.hash(data: Data(text.utf8)).map { String(format: "%02x", $0) }.joined()
    }

    static func base64Encode(_ text: String) -> String {
        Data(text.utf8).base64EncodedString()
    }

    static func base64Decode(_ text: String) -> String? {
        guard let data = Data(base64Encoded: text.trimmingCharacters(in: .whitespacesAndNewlines)) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private static func decodeSegment(_ segment: String) -> String? {
        var base64 = segment.replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/")
        base64 += String(repeating: "=", count: (4 - base64.count % 4) % 4)
        guard let data = Data(base64Encoded: base64),
              let text = String(data: data, encoding: .utf8) else { return nil }
        if case .success(let pretty) = formatJSON(text) { return pretty }
        return text
    }
}

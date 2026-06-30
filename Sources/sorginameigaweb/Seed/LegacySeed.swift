import Foundation
import Vapor

/// Snapshot of the legacy production data, extracted from the live MySQL
/// database (with Latin1 → UTF-8 correction) into `Resources/seed/legacy.json`.
///
/// Because the site's content changes rarely, the data is shipped as a seed
/// rather than imported live, so the new app is self-contained and needs no
/// MySQL connection to stand up. Re-extract the JSON before cutover to refresh.
struct LegacySeed: Codable {
    let counter: Int
    let dogs: [SeedDog]
    let galleries: [SeedGallery]

    struct SeedDog: Codable {
        let id: Int
        let sex: String
        let name: String
        let ancestors: Pedigree
    }

    struct SeedGallery: Codable {
        let id: Int
        let name: String
    }

    /// Loads and decodes `Resources/seed/legacy.json`.
    static func load(from app: Application) throws -> LegacySeed {
        let path = app.directory.resourcesDirectory + "seed/legacy.json"
        let data = try Data(contentsOf: URL(fileURLWithPath: path))
        return try JSONDecoder().decode(LegacySeed.self, from: data)
    }
}

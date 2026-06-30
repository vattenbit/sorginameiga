@testable import sorginameigaweb
import VaporTesting
import Testing

@Suite("Home page")
struct sorginameigawebTests {
    private func withApp(_ test: (Application) async throws -> ()) async throws {
        let app = try await Application.make(.testing)
        do {
            try await configure(app)
            try await test(app)
        } catch {
            try await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }

    @Test("Spanish home renders at / and /es")
    func spanishHome() async throws {
        try await withApp { app in
            for path in ["/", "/es"] {
                try await app.testing().test(.GET, path, afterResponse: { res async in
                    #expect(res.status == .ok)
                    #expect(res.body.string.contains("Criadero Lhasa Apso"))
                    #expect(res.body.string.contains("Pilar Díaz"))
                    #expect(res.body.string.contains("¿Quienes Somos?"))
                })
            }
        }
    }

    @Test("English home renders at /en")
    func englishHome() async throws {
        try await withApp { app in
            try await app.testing().test(.GET, "en", afterResponse: { res async in
                #expect(res.status == .ok)
                #expect(res.body.string.contains("Lhasa Apso Kennel"))
                #expect(res.body.string.contains("About Us"))
            })
        }
    }

    @Test("Legacy seed decodes with correct counts and UTF-8 encoding")
    func legacySeed() async throws {
        try await withApp { app in
            let seed = try LegacySeed.load(from: app)
            #expect(seed.dogs.count == 20)
            #expect(seed.galleries.count == 7)
            #expect(seed.counter == 445682)
            // Latin1 → UTF-8 correction must have been applied at extraction time.
            #expect(seed.dogs.contains { $0.name.contains("SORGIÑA-MEIGA") })
            #expect(seed.galleries.contains { $0.name == "PEQUEÑINES" })
            // Sex values are the preserved legacy strings.
            #expect(Set(seed.dogs.map(\.sex)) == ["macho", "hembra"])
        }
    }
}

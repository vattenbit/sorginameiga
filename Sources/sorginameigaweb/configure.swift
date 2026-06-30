import Fluent
import FluentPostgresDriver
import Leaf
import Vapor

/// Configures the application.
///
/// Phase 2 introduces the data layer: Postgres + Fluent models for the legacy
/// tables, with the production data shipped as a seed (see `LegacySeed`).
func configure(_ app: Application) async throws {
    // Serve static files (CSS, images) from the /Public folder.
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // Database.
    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database",
        tls: .prefer(try .init(configuration: .clientDefault)))
    ), as: .psql)

    // Migrations: schema first, then the legacy data seed.
    app.migrations.add(CreateInitialSchema())
    app.migrations.add(SeedLegacyData(seed: try LegacySeed.load(from: app)))

    // Shared, request-independent localization service.
    app.localization = LocalizationService()

    app.views.use(.leaf)

    // Register routes.
    try routes(app)
}

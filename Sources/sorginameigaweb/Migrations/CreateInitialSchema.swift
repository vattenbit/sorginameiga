import Fluent

/// Creates the initial schema for the public site: dogs, puppies, galleries
/// and the visit counter. Integer ids are user-provided (preserved from the
/// legacy MySQL database), not auto-generated.
struct CreateInitialSchema: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Dog.schema)
            .field("id", .int, .identifier(auto: false))
            .field("name", .string, .required)
            .field("sex", .string, .required)
            .field("pedigree", .json, .required)
            .create()

        try await database.schema(Puppy.schema)
            .field("id", .int, .identifier(auto: false))
            .field("name", .string, .required)
            .field("available", .bool, .required)
            .create()

        try await database.schema(Gallery.schema)
            .field("id", .int, .identifier(auto: false))
            .field("name", .string, .required)
            .create()

        try await database.schema(VisitCounter.schema)
            .field("id", .int, .identifier(auto: false))
            .field("count", .int, .required)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(VisitCounter.schema).delete()
        try await database.schema(Gallery.schema).delete()
        try await database.schema(Puppy.schema).delete()
        try await database.schema(Dog.schema).delete()
    }
}

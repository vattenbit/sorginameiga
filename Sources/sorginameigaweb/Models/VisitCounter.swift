import Fluent

/// The site-wide visit counter. Maps to the legacy single-row `contador`
/// table. Always stored as one row with `id == VisitCounter.singletonID`.
final class VisitCounter: Model, @unchecked Sendable {
    static let schema = "visit_counter"

    /// Fixed id of the single counter row.
    static let singletonID = 1

    @ID(custom: "id", generatedBy: .user)
    var id: Int?

    @Field(key: "count")
    var count: Int

    init() {}

    init(id: Int = VisitCounter.singletonID, count: Int) {
        self.id = id
        self.count = count
    }
}

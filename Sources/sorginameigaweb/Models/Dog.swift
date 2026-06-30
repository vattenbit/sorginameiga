import Fluent

/// A breeding dog. Maps to the legacy `perros` table.
///
/// The integer `id` is preserved from the legacy database because the dog's
/// photos live under `images/<id>/`. `sex` keeps the legacy values
/// (`"macho"` / `"hembra"`); use `Sex` for type-safe access.
final class Dog: Model, @unchecked Sendable {
    static let schema = "dogs"

    @ID(custom: "id", generatedBy: .user)
    var id: Int?

    @Field(key: "name")
    var name: String

    @Field(key: "sex")
    var sex: String

    @Field(key: "pedigree")
    var pedigree: Pedigree

    init() {}

    init(id: Int, name: String, sex: String, pedigree: Pedigree) {
        self.id = id
        self.name = name
        self.sex = sex
        self.pedigree = pedigree
    }
}

/// Type-safe view over the legacy `sexo` string values.
enum Sex: String, Codable, Sendable {
    case male = "macho"
    case female = "hembra"
}

extension Dog {
    var sexValue: Sex? { Sex(rawValue: sex) }
}

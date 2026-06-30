/// A dog's four-generation pedigree, stored as a JSON column.
///
/// Faithful to the legacy `perros` table, where the ancestry was 14 free-text
/// columns (`progenitor_a` … `progenitor_bbb`) holding ancestor names rather
/// than relational references. Letters encode the path from the dog:
/// `a` = sire, `b` = dam, `aa` = paternal grandsire, and so on. An empty string
/// means the ancestor is unknown.
struct Pedigree: Codable, Sendable {
    // Generation 1 — parents
    var a: String   // sire
    var b: String   // dam
    // Generation 2 — grandparents
    var aa: String
    var ab: String
    var ba: String
    var bb: String
    // Generation 3 — great-grandparents
    var aaa: String
    var aab: String
    var aba: String
    var abb: String
    var baa: String
    var bab: String
    var bba: String
    var bbb: String

    /// An all-empty pedigree (no ancestors recorded).
    static let empty = Pedigree(
        a: "", b: "",
        aa: "", ab: "", ba: "", bb: "",
        aaa: "", aab: "", aba: "", abb: "", baa: "", bab: "", bba: "", bbb: ""
    )
}

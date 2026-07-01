import Vapor

/// Admin login page. `error` is true after a failed attempt.
struct AdminLoginContext: Encodable {
    let error: Bool
}

/// Admin dashboard landing page.
struct AdminDashboardContext: Encodable {
    let username: String
}

/// A row in the admin dog list.
struct AdminDogRow: Encodable {
    let id: Int
    let name: String
}

/// Admin dog list page.
struct AdminDogsContext: Encodable {
    let username: String
    let dogs: [AdminDogRow]
}

/// New / edit dog form. `action` is where the form posts; `isNew` toggles the
/// heading. For a new dog the fields are empty.
struct AdminDogFormContext: Encodable {
    let username: String
    let isNew: Bool
    let action: String
    let name: String
    let sex: String
    let pedigree: Pedigree
}

/// Submitted dog form. HTML always sends every named field (empty = ""), so the
/// pedigree fields are plain (non-optional) strings.
struct DogForm: Content {
    var name: String
    var sex: String
    var a: String, b: String
    var aa: String, ab: String, ba: String, bb: String
    var aaa: String, aab: String, aba: String, abb: String
    var baa: String, bab: String, bba: String, bbb: String

    var pedigree: Pedigree {
        Pedigree(
            a: a, b: b,
            aa: aa, ab: ab, ba: ba, bb: bb,
            aaa: aaa, aab: aab, aba: aba, abb: abb,
            baa: baa, bab: bab, bba: bba, bbb: bbb
        )
    }
}

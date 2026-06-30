/// Supported site languages.
///
/// Mirrors the legacy `?idioma=esp|ing` switch (see `old_web/idioma.php`),
/// now resolved from clean URLs: Spanish lives at the root (`/`, `/es`) and
/// English at `/en`. Spanish is the default, matching the legacy behaviour.
enum Language: String, Sendable {
    case esp
    case ing

    /// Default language when none is specified (legacy default was Spanish).
    static let `default`: Language = .esp

    /// The other language, used to build the header's language switcher.
    var alternate: Language {
        switch self {
        case .esp: return .ing
        case .ing: return .esp
        }
    }

    /// Value for the HTML `lang` attribute (e.g. "es" / "en").
    var htmlLang: String {
        switch self {
        case .esp: return "es"
        case .ing: return "en"
        }
    }

    /// Absolute URL of this language's home page.
    var homeURL: String {
        switch self {
        case .esp: return "/"
        case .ing: return "/en"
        }
    }
}

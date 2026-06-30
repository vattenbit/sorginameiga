/// A navigation menu entry (label + destination URL).
struct MenuItem: Encodable {
    let label: String
    let url: String
}

/// View context shared by the layout and the home page.
///
/// Carries everything the Leaf templates need: the current language, the
/// language-switcher targets, the localized menu and the translated strings.
struct PageContext: Encodable {
    /// Value for the HTML `lang` attribute ("es" / "en").
    let lang: String
    /// Home URL of the Spanish site (target of the "esp" flag).
    let spanishURL: String
    /// Home URL of the English site (target of the "ing" flag).
    let englishURL: String
    /// Localized navigation menu.
    let menu: [MenuItem]
    /// Total visit count for the footer, or `nil` if the counter is unavailable.
    let visitCount: Int?
    /// Translated strings for the current language.
    let t: Translation
}

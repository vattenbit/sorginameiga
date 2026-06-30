import Fluent
import Vapor

/// Serves the public home page ("¿Quiénes Somos?") in both languages.
///
/// Clean URLs: `/` and `/es` render Spanish, `/en` renders English.
/// Replaces the legacy `old_web/index.php`.
final class HomeController: RouteCollection, Sendable {
    func boot(routes: any RoutesBuilder) throws {
        routes.get(use: spanishHome)       // /
        routes.get("es", use: spanishHome) // /es
        routes.get("en", use: englishHome) // /en
    }

    @Sendable
    func spanishHome(req: Request) async throws -> View {
        try await render(.esp, on: req)
    }

    @Sendable
    func englishHome(req: Request) async throws -> View {
        try await render(.ing, on: req)
    }

    /// Builds the page context for the given language and renders the home view.
    private func render(_ language: Language, on req: Request) async throws -> View {
        let translation = req.localization.translation(for: language)
        let context = PageContext(
            lang: language.htmlLang,
            spanishURL: Language.esp.homeURL,
            englishURL: Language.ing.homeURL,
            menu: menu(for: language, translation: translation),
            visitCount: await registerVisit(on: req),
            t: translation
        )
        return try await req.view.render("home", context)
    }

    /// Increments and returns the site-wide visit counter, mirroring the legacy
    /// footer behaviour. Best-effort: returns `nil` if the database is
    /// unavailable so the page still renders.
    private func registerVisit(on req: Request) async -> Int? {
        do {
            guard let counter = try await VisitCounter.find(VisitCounter.singletonID, on: req.db) else {
                return nil
            }
            counter.count += 1
            try await counter.save(on: req.db)
            return counter.count
        } catch {
            req.logger.warning("Visit counter unavailable: \(error)")
            return nil
        }
    }

    /// Builds the localized navigation menu.
    ///
    /// Note: in this first phase only the "About" entry resolves; the remaining
    /// sections (dogs, puppies, gallery, contact) are implemented in later phases
    /// and will respond on these planned URLs.
    private func menu(for language: Language, translation t: Translation) -> [MenuItem] {
        switch language {
        case .esp:
            return [
                MenuItem(label: t.aboutUs, url: "/"),
                MenuItem(label: t.males, url: "/machos"),
                MenuItem(label: t.females, url: "/hembras"),
                MenuItem(label: t.puppies, url: "/cachorros"),
                MenuItem(label: t.gallery, url: "/galeria"),
                MenuItem(label: t.contact, url: "/contacto"),
            ]
        case .ing:
            return [
                MenuItem(label: t.aboutUs, url: "/en"),
                MenuItem(label: t.males, url: "/en/males"),
                MenuItem(label: t.females, url: "/en/females"),
                MenuItem(label: t.puppies, url: "/en/puppies"),
                MenuItem(label: t.gallery, url: "/en/gallery"),
                MenuItem(label: t.contact, url: "/en/contact"),
            ]
        }
    }
}

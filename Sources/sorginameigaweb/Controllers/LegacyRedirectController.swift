import Vapor

/// Permanent (301) redirects from the legacy PHP URLs to the new clean routes,
/// so existing inbound links and search-engine rankings are preserved after the
/// cutover. Language is taken from the legacy `?idioma=esp|ing` query param.
///
/// Examples:
///   /index.php?idioma=ing          -> /en
///   /perros.php?sexo=macho         -> /machos
///   /verperro.php?id=27&idioma=ing -> /en/dog/27
///   /galeria.php                   -> /galeria
final class LegacyRedirectController: RouteCollection, Sendable {
    func boot(routes: any RoutesBuilder) throws {
        routes.get("index.php", use: home)
        routes.get("perros.php", use: dogs)
        routes.get("verperro.php", use: dogDetail)
        routes.get("cachorros.php", use: puppies)
        routes.get("galeria.php", use: gallery)
        routes.get("contactos.php", use: contact)
    }

    @Sendable func home(req: Request) -> Response {
        move(req, to: english(req) ? "/en" : "/")
    }

    @Sendable func dogs(req: Request) -> Response {
        let sex = req.query[String.self, at: "sexo"]
        let target: String
        switch (sex, english(req)) {
        case ("hembra", true): target = "/en/females"
        case ("hembra", false): target = "/hembras"
        case (_, true): target = "/en/males"
        default: target = "/machos"
        }
        return move(req, to: target)
    }

    @Sendable func dogDetail(req: Request) -> Response {
        guard let id = req.query[Int.self, at: "id"] else {
            return move(req, to: english(req) ? "/en/males" : "/machos")
        }
        return move(req, to: english(req) ? "/en/dog/\(id)" : "/perro/\(id)")
    }

    @Sendable func puppies(req: Request) -> Response {
        move(req, to: english(req) ? "/en/puppies" : "/cachorros")
    }

    @Sendable func gallery(req: Request) -> Response {
        move(req, to: english(req) ? "/en/gallery" : "/galeria")
    }

    @Sendable func contact(req: Request) -> Response {
        move(req, to: english(req) ? "/en/contact" : "/contacto")
    }

    // MARK: - Helpers

    /// Legacy language flag: `idioma=ing` means English; anything else Spanish.
    private func english(_ req: Request) -> Bool {
        req.query[String.self, at: "idioma"] == "ing"
    }

    private func move(_ req: Request, to path: String) -> Response {
        req.redirect(to: path, redirectType: .permanent)
    }
}

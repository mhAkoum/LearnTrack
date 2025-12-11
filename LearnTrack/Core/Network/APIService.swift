import Foundation

// MARK: - API Service

class APIService {
    static let shared = APIService()
    private let baseURL = "https://www.formateurs-numerique.com/api"

    private init() {}

    // MARK: - Generic Request

    private func request<T: Decodable>(_ endpoint: String, method: String = "GET", body: [String: Any]? = nil) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let body = body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200, 201:
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        case 204:
            throw APIError.noContent
        case 400:
            throw APIError.badRequest
        case 404:
            throw APIError.notFound
        default:
            throw APIError.serverError(httpResponse.statusCode)
        }
    }

    private func requestNoContent(_ endpoint: String, method: String, body: [String: Any]? = nil) async throws {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let body = body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard httpResponse.statusCode == 204 else {
            throw APIError.serverError(httpResponse.statusCode)
        }
    }

    // MARK: - Health

    func checkHealth() async throws -> HealthResponse {
        try await request("/health")
    }

    func checkDatabaseHealth() async throws -> DatabaseHealthResponse {
        try await request("/health/db")
    }

    // MARK: - Auth

    /// Connexion avec email et mot de passe
    func login(email: String, password: String) async throws -> AuthResponse {
        let body: [String: Any] = ["email": email, "password": password]
        return try await request("/auth/login", method: "POST", body: body)
    }

    /// Inscription d'un nouvel utilisateur
    func register(email: String, password: String, nom: String, prenom: String) async throws -> AuthResponse {
        let body: [String: Any] = [
            "email": email,
            "password": password,
            "nom": nom,
            "prenom": prenom
        ]
        return try await request("/auth/register", method: "POST", body: body)
    }

    // MARK: - Clients

    func getClients() async throws -> [Client] {
        try await request("/clients")
    }

    func getClient(id: Int) async throws -> Client {
        try await request("/clients/\(id)")
    }

    func createClient(_ client: ClientCreate) async throws -> Client {
        let body = client.toDictionary()
        return try await request("/clients", method: "POST", body: body)
    }

    func updateClient(id: Int, _ client: ClientUpdate) async throws -> Client {
        let body = client.toDictionary()
        return try await request("/clients/\(id)", method: "PUT", body: body)
    }

    func deleteClient(id: Int) async throws {
        try await requestNoContent("/clients/\(id)", method: "DELETE")
    }

    func getClientSessions(clientId: Int) async throws -> [Session] {
        try await request("/clients/\(clientId)/sessions")
    }

    // MARK: - Ecoles

    func getEcoles() async throws -> [Ecole] {
        try await request("/ecoles")
    }

    func getEcole(id: Int) async throws -> Ecole {
        try await request("/ecoles/\(id)")
    }

    func createEcole(_ ecole: EcoleCreate) async throws -> Ecole {
        let body = ecole.toDictionary()
        return try await request("/ecoles", method: "POST", body: body)
    }

    func updateEcole(id: Int, _ ecole: EcoleUpdate) async throws -> Ecole {
        let body = ecole.toDictionary()
        return try await request("/ecoles/\(id)", method: "PUT", body: body)
    }

    func deleteEcole(id: Int) async throws {
        try await requestNoContent("/ecoles/\(id)", method: "DELETE")
    }

    func getEcoleSessions(ecoleId: Int) async throws -> [Session] {
        try await request("/ecoles/\(ecoleId)/sessions")
    }

    // MARK: - Formateurs

    func getFormateurs() async throws -> [Formateur] {
        try await request("/formateurs")
    }

    func getFormateur(id: Int) async throws -> Formateur {
        try await request("/formateurs/\(id)")
    }

    func createFormateur(_ formateur: FormateurCreate) async throws -> Formateur {
        let body = formateur.toDictionary()
        return try await request("/formateurs", method: "POST", body: body)
    }

    func updateFormateur(id: Int, _ formateur: FormateurUpdate) async throws -> Formateur {
        let body = formateur.toDictionary()
        return try await request("/formateurs/\(id)", method: "PUT", body: body)
    }

    func deleteFormateur(id: Int) async throws {
        try await requestNoContent("/formateurs/\(id)", method: "DELETE")
    }

    func getFormateurSessions(formateurId: Int) async throws -> [Session] {
        try await request("/formateurs/\(formateurId)/sessions")
    }

    // MARK: - Sessions

    func getSessions() async throws -> [Session] {
        try await request("/sessions")
    }

    func getSession(id: Int) async throws -> Session {
        try await request("/sessions/\(id)")
    }

    func createSession(_ session: SessionCreate) async throws -> Session {
        let body = session.toDictionary()
        return try await request("/sessions", method: "POST", body: body)
    }

    func updateSession(id: Int, _ session: SessionUpdate) async throws -> Session {
        let body = session.toDictionary()
        return try await request("/sessions/\(id)", method: "PUT", body: body)
    }

    func deleteSession(id: Int) async throws {
        try await requestNoContent("/sessions/\(id)", method: "DELETE")
    }

    // MARK: - Users

    func getUsers() async throws -> [User] {
        try await request("/users")
    }

    func getUser(id: Int) async throws -> User {
        try await request("/users/\(id)")
    }

    func createUser(_ user: UserCreate) async throws -> User {
        let body = user.toDictionary()
        return try await request("/users", method: "POST", body: body)
    }

    func updateUser(id: Int, _ user: UserUpdate) async throws -> User {
        let body = user.toDictionary()
        return try await request("/users/\(id)", method: "PUT", body: body)
    }

    func deleteUser(id: Int) async throws {
        try await requestNoContent("/users/\(id)", method: "DELETE")
    }
}

// MARK: - Health Models

struct HealthResponse: Codable {
    let status: String
}

struct DatabaseHealthResponse: Codable {
    let status: String
    let database: String
}

// MARK: - Auth Models

struct AuthResponse: Codable {
    let success: Bool
    let message: String
    let user: User?
}


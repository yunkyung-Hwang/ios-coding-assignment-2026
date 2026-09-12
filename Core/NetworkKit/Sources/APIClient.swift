public protocol APIClient: Sendable {
    func send<Response>(_ request: Request<Response>) async throws -> Response
}

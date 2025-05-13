protocol KeychainServiceProtocol {
    func getPassword() -> String?
    func savePassword(_ password: String)
    func updatePassword(_ password: String)
}

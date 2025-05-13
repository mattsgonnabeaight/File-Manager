import Foundation
import KeychainAccess

final class KeychainService: KeychainServiceProtocol {
    private let keychain = Keychain(service: "com.yourapp.documents")
    private let passwordKey = "userPassword"

    func getPassword() -> String? {
        return keychain[passwordKey]
    }

    func savePassword(_ password: String) {
        keychain[passwordKey] = password
    }

    func updatePassword(_ password: String) {
        keychain[passwordKey] = password
    }
}

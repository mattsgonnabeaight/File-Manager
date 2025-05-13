import Foundation

final class UserDefaultsService: UserDefaultsServiceProtocol {
    private let sortKey = "isAlphabeticalSortEnabled"
    private let sizeKey = "isImageSizeVisible"

    func loadSettings() -> Settings {
        let sort = UserDefaults.standard.bool(forKey: sortKey)
        let size = UserDefaults.standard.bool(forKey: sizeKey)
        return Settings(isAlphabeticalSortEnabled: sort, isImageSizeVisible: size)
    }

    func saveSettings(_ settings: Settings) {
        UserDefaults.standard.set(settings.isAlphabeticalSortEnabled, forKey: sortKey)
        UserDefaults.standard.set(settings.isImageSizeVisible, forKey: sizeKey)
    }
}

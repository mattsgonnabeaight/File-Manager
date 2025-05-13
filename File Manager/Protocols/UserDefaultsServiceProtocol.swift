protocol UserDefaultsServiceProtocol {
    func loadSettings() -> Settings
    func saveSettings(_ settings: Settings)
}

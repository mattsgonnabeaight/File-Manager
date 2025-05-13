import UIKit

final class SettingsViewController: UITableViewController {

    private let userDefaultsService: UserDefaultsServiceProtocol
    private var settings: Settings

    init(userDefaultsService: UserDefaultsServiceProtocol = UserDefaultsService()) {
        self.userDefaultsService = userDefaultsService
        self.settings = userDefaultsService.loadSettings()
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) { fatalError() }

    enum Section: Int, CaseIterable {
        case options, actions
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Настройки"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == Section.options.rawValue ? 2 : 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        switch Section(rawValue: indexPath.section)! {
        case .options:
            let toggle = UISwitch()
            toggle.tag = indexPath.row
            toggle.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)

            if indexPath.row == 0 {
                cell.textLabel?.text = "Сортировка (А → Я)"
                toggle.isOn = settings.isAlphabeticalSortEnabled
            } else {
                cell.textLabel?.text = "Показывать размер фото"
                toggle.isOn = settings.isImageSizeVisible
            }

            cell.accessoryView = toggle

        case .actions:
            cell.textLabel?.text = "Сменить пароль"
            cell.accessoryType = .disclosureIndicator
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == Section.actions.rawValue {
            let changePasswordVC = PasswordViewController(keychainService: KeychainService())
            changePasswordVC.modalPresentationStyle = .formSheet
            present(changePasswordVC, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    @objc private func switchChanged(_ sender: UISwitch) {
        if sender.tag == 0 {
            settings.isAlphabeticalSortEnabled = sender.isOn
        } else {
            settings.isImageSizeVisible = sender.isOn
        }
        userDefaultsService.saveSettings(settings)
    }
}

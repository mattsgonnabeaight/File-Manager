import UIKit

final class PasswordViewController: UIViewController {

    private let keychainService: KeychainServiceProtocol
    private var isPasswordSet: Bool
    private var isConfirmingPassword = false
    private var firstPasswordInput: String?
    private let fileManagerService: FileManagerServiceProtocol = FileManagerService()

    private let textField = UITextField()
    private let button = UIButton(type: .system)
    private let errorLabel = UILabel()

    init(keychainService: KeychainServiceProtocol) {
        self.keychainService = keychainService
        self.isPasswordSet = keychainService.getPassword() != nil
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
    }

    private func setupUI() {
        textField.placeholder = "Введите пароль"
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect

        button.setTitle(isPasswordSet ? "Введите пароль" : "Создать пароль", for: .normal)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)

        errorLabel.textColor = .systemRed
        errorLabel.numberOfLines = 0
        errorLabel.font = .systemFont(ofSize: 14)

        let stack = UIStackView(arrangedSubviews: [textField, button, errorLabel])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }

    @objc private func buttonTapped() {
        guard let text = textField.text, text.count >= 4 else {
            showError("Пароль должен содержать минимум 4 символа")
            return
        }

        if isPasswordSet {
            if keychainService.getPassword() == text {
                presentMainTabBar()
            } else {
                showError("Неверный пароль")
            }
        } else {
            if isConfirmingPassword {
                if firstPasswordInput == text {
                    keychainService.savePassword(text)
                    presentMainTabBar()
                } else {
                    showError("Пароли не совпадают")
                    resetInput()
                }
            } else {
                firstPasswordInput = text
                isConfirmingPassword = true
                button.setTitle("Повторите пароль", for: .normal)
                textField.text = nil
            }
        }
    }

    private func showError(_ message: String) {
        errorLabel.text = message
    }

    private func resetInput() {
        isConfirmingPassword = false
        firstPasswordInput = nil
        button.setTitle("Создать пароль", for: .normal)
        textField.text = nil
    }

    private func presentMainTabBar() {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileVC = DirectoryViewController(directoryURL: path, fileManagerService: fileManagerService)
        let settingsVC = SettingsViewController()

        let tabBarController = UITabBarController()
        fileVC.tabBarItem = UITabBarItem(title: "Файлы", image: UIImage(systemName: "folder"), tag: 0)
        settingsVC.tabBarItem = UITabBarItem(title: "Настройки", image: UIImage(systemName: "gear"), tag: 1)
        tabBarController.viewControllers = [UINavigationController(rootViewController: fileVC),
                                            UINavigationController(rootViewController: settingsVC)]

        tabBarController.modalPresentationStyle = .fullScreen
        present(tabBarController, animated: true, completion: nil)
    }
}

import UIKit

class DirectoryViewController: UITableViewController {
    private let fileManagerService: FileManagerServiceProtocol
    private var contents: [Content] = []
    private var currentDirectory: URL

    init(directoryURL: URL, fileManagerService: FileManagerServiceProtocol) {
        self.currentDirectory = directoryURL
        self.fileManagerService = fileManagerService
        super.init(style: .plain)
        self.title = directoryURL.lastPathComponent
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        loadContents()
    }

    private func setupNavigationBar() {
        title = "Documents"

        let folderButton = UIBarButtonItem(
            image: UIImage(systemName: "folder.badge.plus"),
            style: .plain,
            target: self,
            action: #selector(createFolderTapped)
        )

        let photoButton = UIBarButtonItem(
            image: UIImage(systemName: "photo.on.rectangle"),
            style: .plain,
            target: self,
            action: #selector(addPhotoTapped)
        )

        navigationItem.rightBarButtonItems = [photoButton, folderButton]
    }

    private func loadContents() {
        contents = fileManagerService.contentsOfDirectory(at: currentDirectory)
        tableView.reloadData()
    }

    @objc private func createFolderTapped() {
        let alert = UIAlertController(title: "Новая папка", message: "Введите имя папки", preferredStyle: .alert)
        alert.addTextField()

        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Создать", style: .default, handler: { [weak self] _ in
            guard let folderName = alert.textFields?.first?.text, !folderName.isEmpty else { return }
            do {
                try self?.fileManagerService.createDirectory(named: folderName, at: self!.currentDirectory)
                self?.loadContents()
            } catch {
                print("Ошибка создания папки: \(error)")
            }
        }))
        present(alert, animated: true)
    }

    @objc private func addPhotoTapped() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        contents.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let content = contents[indexPath.row]
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = content.name
        if content.type == .folder {
            cell.accessoryType = .disclosureIndicator
        } else {
            cell.selectionStyle = .none
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let content = contents[indexPath.row]
        guard content.type == .folder else { return }
        let vc = DirectoryViewController(directoryURL: content.url, fileManagerService: fileManagerService)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension DirectoryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.originalImage] as? UIImage else { return }
        let name = "image_\(UUID().uuidString).jpg"
        do {
            try fileManagerService.createFile(with: image, named: name, at: currentDirectory)
            loadContents()
        } catch {
            print("Ошибка сохранения изображения: \(error)")
        }
    }
}

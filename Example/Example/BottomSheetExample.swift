import WordPressUI

class BottomSheetExample {

    weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func showBottomSheet() {
        guard let viewController = viewController else { return }
        let childViewController = BottomViewController()
        let bottomSheet = BottomSheetViewController(childViewController: childViewController)
        bottomSheet.show(from: viewController)
    }
}

class BottomViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let label1 = UILabel(frame: .zero)
        label1.translatesAutoresizingMaskIntoConstraints = false
        label1.text = "Hello"

        let label2 = UILabel(frame: .zero)
        label2.translatesAutoresizingMaskIntoConstraints = false
        label2.text = "There"

        let stackView = UIStackView(arrangedSubviews: [
            label1,
            label2
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension BottomViewController: DrawerPresentable {
    
}

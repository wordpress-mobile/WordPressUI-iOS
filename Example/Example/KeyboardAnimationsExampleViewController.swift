import UIKit

class KeyboardAnimationsExampleViewController: UIViewController {
    @IBOutlet weak var textView: UITextField!
    @IBOutlet weak var bottomConstraintForAnimation: NSLayoutConstraint!
    private var notificationObservers: [NSObjectProtocol] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        startObservingKeyboardChanges()
    }

    deinit {
        stopObservingKeyboardChanges()
    }

    @IBAction func didTapButton(_ sender: Any) {
        if textView.isFirstResponder {
            textView.resignFirstResponder()
        } else {
            textView.becomeFirstResponder()
        }
    }

    private func keybaordDidOpen(_ endFrame: CGRect) {
        bottomConstraintForAnimation.constant = endFrame.height - self.view.safeAreaInsets.bottom + 10
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    func startObservingKeyboardChanges() {
        let willShowObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { (notification) in
            UIView.animate(withKeyboard: notification) { (_, endFrame) in
                self.keybaordDidOpen(endFrame)
            }
        }

        let willHideObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { (notification) in
            UIView.animate(withKeyboard: notification) { (beginFrame, endFrame) in
                self.bottomConstraintForAnimation.constant = 20
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            }
        }

        let willChangeFrameObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: .main) { (notification) in
            UIView.animate(withKeyboard: notification) { (_, endFrame) in
                self.keybaordDidOpen(endFrame)
            }
        }

        notificationObservers.append(willShowObserver)
        notificationObservers.append(willHideObserver)
        notificationObservers.append(willChangeFrameObserver)
    }

    private func stopObservingKeyboardChanges() {
        notificationObservers.forEach { (observer) in
            NotificationCenter.default.removeObserver(observer)
        }
        notificationObservers = []
    }
}

import WordPressUI

class FancyAlertExample {

    weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    private struct FancyAlertConstants {
        static let title = "Fancy Alert"
        static let message = "Introducing the Fancy Alert UI Experience. Designed to show alerts and information to the user in a standardized manner."

        static let defaultButtonTitle =  "Go Ahead"
        static let cancelButtonTitle = "Cancel"
        static let moreInfoButtonTitle = "More Information"

        static let switchText = "Do not show this again"
    }

    func showFancyAlert(moreInfoButton: FancyAlertViewController.Config.ButtonConfig? = nil,
                        switchConfig: FancyAlertViewController.Config.SwitchConfig? = nil) {

        let defaultButton = FancyAlertViewController.Config.ButtonConfig(FancyAlertConstants.defaultButtonTitle) { (controller: FancyAlertViewController, button: UIButton) in

            self.show(message: FancyAlertConstants.defaultButtonTitle, from: controller) {
                controller.dismiss(animated: true)
            }
        }

        let cancelButton = FancyAlertViewController.Config.ButtonConfig(FancyAlertConstants.cancelButtonTitle) { (controller: FancyAlertViewController, button: UIButton) in
            controller.dismiss(animated: true)
        }

        let configuration = FancyAlertViewController.Config(
            titleText: FancyAlertConstants.title,
            bodyText: FancyAlertConstants.message,
            headerImage: nil,
            dividerPosition: nil,
            defaultButton: defaultButton,
            cancelButton: cancelButton,
            moreInfoButton: moreInfoButton,
            switchConfig: switchConfig)

        let alert = FancyAlertViewController.controllerWithConfiguration(configuration: configuration)
        alert.modalPresentationStyle = .custom
        alert.transitioningDelegate = viewController as? UIViewControllerTransitioningDelegate

        viewController?.present(alert, animated: true, completion: nil)
    }

    func showFancyAlertWithMoreInfo() {
        let moreInfoButton = FancyAlertViewController.Config.ButtonConfig(FancyAlertConstants.moreInfoButtonTitle) { [unowned self] (controller: FancyAlertViewController, button: UIButton) in

            self.show(message: FancyAlertConstants.moreInfoButtonTitle, from: controller)
        }

        showFancyAlert(moreInfoButton: moreInfoButton)
    }

    func showFancyAlertWithSwitch() {
        let switchConfig = FancyAlertViewController.Config.SwitchConfig(
            initialValue: true,
            text: FancyAlertConstants.switchText,
            action: { (controller, theSwitch) in
                if theSwitch.isOn {
                    self.show(message: "ON", from: controller)
                } else {
                    self.show(message: "OFF", from: controller)
                }
        })

        showFancyAlert(switchConfig: switchConfig)
    }

    private func show(message: String, from controller: UIViewController, completion onCompletion: (() -> Void)? = nil) {
        let alertViewController = UIAlertController(title: nil, message: message, preferredStyle: .alert)

        alertViewController.addActionWithTitle("Ok", style: .default) { alertAction in
            onCompletion?()
        }

        controller.present(alertViewController, animated: true, completion: nil)
    }

}

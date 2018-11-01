import UIKit
import WordPressUI

///
///
class ViewController: UITableViewController
{
    
    private typealias CompletionClosure = () -> ()
    
    let cellIdentifier = "CellIdentifier"
    var sections: [DemoSection]!
    
    // MARK: LifeCycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sections = [
            DemoSection(title: "Fancy Alert", rows: [
                DemoRow(title: "Fancy Alert", action: {
                    self.showFancyAlert()
                }),
                DemoRow(title: "Fancy Alert (Full)", action: {
                    self.showFancyAlertWithMoreInfo()
                }),
                DemoRow(title: "Fancy Alert (Switch)", action: {
                    self.showFancyAlertWithSwitch()
                })]
            ),
            DemoSection(title: "Misc UI Elements", rows: []),
        ]
    }
    
    // MARK: - Useful constants
    
    private struct FancyAlertConstants {
        static let title = "Fancy Alert"
        static let message = "Introducing the Fancy Alert UI Experience. Designed to show alerts and information to the user in a standardized manner."
        
        static let defaultButtonTitle =  "Go Ahead"
        static let cancelButtonTitle = "Cancel"
        static let moreInfoButtonTitle = "More Information"
        
        static let switchText = "Do not show this again"
    }
    
    // MARK: Fancy Alert
    
    func showFancyAlert(
        moreInfoButton: FancyAlertViewController.Config.ButtonConfig? = nil,
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
        alert.transitioningDelegate = self
        
        present(alert, animated: true, completion: nil)
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
    
    // MARK: - Test Messages for the User
    
    private func show(message: String, from controller: UIViewController, completion onCompletion: CompletionClosure? = nil) {
        let alertViewController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        alertViewController.addActionWithTitle("Ok", style: .default) { alertAction in
            onCompletion?()
        }
        
        controller.present(alertViewController, animated: true, completion: nil)
    }
    
    // MARK: - TableView Methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)!
        cell.accessoryType = .disclosureIndicator
        
        let row = sections[indexPath.section].rows[indexPath.row]
        cell.textLabel?.text = row.title
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let textView = UITextView()
        
        textView.font = UIFont.boldSystemFont(ofSize: 14)
        textView.textAlignment = .center
        textView.isEditable = false
        textView.text = sections[section].title
        textView.backgroundColor = UIColor.lightGray
        
        return textView
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        sections[indexPath.section].rows[indexPath.row].action()
    }
    
}

// MARK: - UIViewControllerTransitioningDelegate
//
extension ViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        guard presented is FancyAlertViewController else {
            return nil
        }
        
        return FancyAlertPresentationController(presentedViewController: presented, presenting: presenting)
    }
}


typealias RowAction = () -> Void

struct DemoSection {
    var title: String
    var rows: [DemoRow]
}

struct DemoRow {
    var title: String
    var action: RowAction
}

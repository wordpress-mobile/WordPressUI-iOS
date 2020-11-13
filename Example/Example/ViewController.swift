import UIKit
import WordPressUI

///
///
class ViewController: UITableViewController
{
        
    let cellIdentifier = "CellIdentifier"
    var sections: [DemoSection]!

    // MARK: LifeCycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let fancyAlert = FancyAlertExample(viewController: self)
        let bottomSheet = BottomSheetExample(viewController: self)
        
        sections = [
            DemoSection(title: "Fancy Alert", rows: [
                DemoRow(title: "Fancy Alert", action: {
                    fancyAlert.showFancyAlert()
                }),
                DemoRow(title: "Fancy Alert (Full)", action: {
                    fancyAlert.showFancyAlertWithMoreInfo()
                }),
                DemoRow(title: "Fancy Alert (Switch)", action: {
                    fancyAlert.showFancyAlertWithSwitch()
                })]
            ),
            DemoSection(title: "Misc UI Elements", rows: [
                DemoRow(title: "Fancy Buttons", action: {
                    self.showFancyButtons()
                })
            ]),
            DemoSection(title: "Bottom Sheet", rows: [
                DemoRow(title: "Bottom Sheet", action: {
                    bottomSheet.showBottomSheet()
                })
            ])
        ]
    }
            
    // MARK: - Fancy Buttons

    func showFancyButtons() {
        performSegue(withIdentifier: "FancyButtonsSegue", sender: self)
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

class FancyButtonsViewController: UIViewController {}

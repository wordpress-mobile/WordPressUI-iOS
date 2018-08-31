import Foundation
import UIKit


/// GhostTableViewHandler: Encapsulates all of the methods required to setup a "Ghost UICollectionView".
///
class GhostTableViewHandler: NSObject {

    /// Ghost Settings!
    ///
    let settings: GhostSettings


    /// Designated Initializer
    ///
    init(using settings: GhostSettings) {
        self.settings = settings
    }
}


/// GhostTableViewHandler: DataSource Methods
///
extension GhostTableViewHandler: UITableViewDataSource {

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return settings.displaysSectionHeader ? " " : nil
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return settings.rowsPerSection.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.rowsPerSection[section]
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: settings.reuseIdentifier, for: indexPath)
        cell.insertGhostLayers { layer in
            layer.backgroundColor = settings.beatStartColor.cgColor
            layer.startAnimating(fromColor: settings.beatStartColor, toColor: settings.beatEndColor, duration: settings.beatDuration)
        }

        return cell
    }
}


/// GhostTableViewHandler: Delegate Methods
///
extension GhostTableViewHandler: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

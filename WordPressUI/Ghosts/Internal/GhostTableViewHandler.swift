import Foundation
import UIKit


/// GhostTableViewHandler: Encapsulates all of the methods required to setup a "Ghost UICollectionView".
///
class GhostTableViewHandler: NSObject {

    /// ReuseIdentifier to be used on each one of the Ghost Cells.
    ///
    let reuseIdentifier: String

    /// Structure to be displayed.
    ///
    let rowsPerSection: [Int]


    /// Designated Initializer
    ///
    init(reuseIdentifier: String, rowsPerSection: [Int]) {
        self.reuseIdentifier = reuseIdentifier
        self.rowsPerSection = rowsPerSection
    }
}


/// GhostTableViewHandler: DataSource Methods
///
extension GhostTableViewHandler: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return rowsPerSection.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowsPerSection[section]
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        cell.insertAnimatedGhostLayers()
        return cell
    }
}


/// GhostTableViewHandler: Delegate Methods
///
extension GhostTableViewHandler: UITableViewDelegate { }

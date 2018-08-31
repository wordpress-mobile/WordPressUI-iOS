import Foundation
import UIKit


/// GhostCollectionViewHandler: Encapsulates all of the methods required to setup a "Ghost UICollectionView".
///
class GhostCollectionViewHandler: NSObject {

    /// ReuseIdentifier to be used on each one of the Ghost Cells.
    ///
    let reuseIdentifier: String

    /// Structure to be displayed.
    ///
    let itemsPerSection: [Int]


    /// Designated Initializer
    ///
    init(reuseIdentifier: String, itemsPerSection: [Int]) {
        self.reuseIdentifier = reuseIdentifier
        self.itemsPerSection = itemsPerSection
    }
}


/// SkeletonCollectionViewHandler: DataSource Methods
///
extension GhostCollectionViewHandler: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return itemsPerSection.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsPerSection[section]
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        cell.insertGhostLayers()
        return cell
    }
}


/// SkeletonCollectionViewHandler: Delegate Methods
///
extension GhostCollectionViewHandler: UICollectionViewDelegate { }

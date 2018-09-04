import Foundation
import UIKit


/// GhostCollectionViewHandler: Encapsulates all of the methods required to setup a "Ghost UICollectionView".
///
class GhostCollectionViewHandler: NSObject {

    /// Ghost Settings!
    ///
    let settings: GhostSettings


    /// Designated Initializer
    ///
    init(using settings: GhostSettings) {
        self.settings = settings
    }
}


/// SkeletonCollectionViewHandler: DataSource Methods
///
extension GhostCollectionViewHandler: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return settings.rowsPerSection.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return settings.rowsPerSection[section]
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: settings.reuseIdentifier, for: indexPath)
        cell.insertGhostLayers { layer in
            layer.backgroundColor = settings.beatStartColor.cgColor
            layer.startAnimating(fromColor: settings.beatStartColor, toColor: settings.beatEndColor, duration: settings.beatDuration)
        }

        return cell
    }
}


/// SkeletonCollectionViewHandler: Delegate Methods
///
extension GhostCollectionViewHandler: UICollectionViewDelegate { }

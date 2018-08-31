import Foundation
import UIKit


// MARK: - Skeleton UICollectionView Methods
//
extension UICollectionView {

    /// Displays Ghost Content, based on cells with the given reuseIdentifier, and items hieararchy.
    ///
    open func displayGhostContent(using settings: GhostSettings) {
        guard ghostHandler == nil else {
            return
        }

        preserveInitialDelegates()
        setupGhostHandler(using: settings)

        reloadData()
    }

    /// Nukes the Ghost Style.
    ///
    open func removeGhostContent() {
        guard ghostHandler != nil else {
            return
        }

        restoreInitialDelegates()
        resetAssociatedReferences()
        removeGhostLayers()

        reloadData()
    }
}


// MARK: - Private Methods
//
private extension UICollectionView {

    /// Sets up an internal (private) instance of GhostCollectionViewHandler.
    ///
    func setupGhostHandler(using settings: GhostSettings) {
        let handler = GhostCollectionViewHandler(using: settings)
        dataSource = handler
        delegate = handler
        ghostHandler = handler
    }

    /// Preserves the DataSource + Delegate.
    ///
    func preserveInitialDelegates() {
        initialDataSource = dataSource
        initialDelegate = delegate
    }

    /// Restores the initial DataSource + Delegate.
    ///
    func restoreInitialDelegates() {
        dataSource = initialDataSource
        delegate = initialDelegate
    }

    /// Cleans up all of the (private) internal references.
    ///
    func resetAssociatedReferences() {
        initialDataSource = nil
        initialDelegate = nil
        ghostHandler = nil
    }
}


// MARK: - Private "Associated" Properties
//
private extension UICollectionView {

    /// Reference to the GhostHandler.
    ///
    var ghostHandler: GhostCollectionViewHandler? {
        get {
            return objc_getAssociatedObject(self, &Keys.ghostHandler) as? GhostCollectionViewHandler
        }
        set {
            objc_setAssociatedObject(self, &Keys.ghostHandler, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    /// UICollectionViewDataSource state, previous to mapping the GhostHandler.
    ///
    var initialDataSource: UICollectionViewDataSource? {
        get {
            return objc_getAssociatedObject(self, &Keys.originalDataSource) as? UICollectionViewDataSource
        }
        set {
            objc_setAssociatedObject(self, &Keys.originalDataSource, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    /// UICollectionViewDelegate state, previous to mapping the GhostHandler.
    ///
    var initialDelegate: UICollectionViewDelegate? {
        get {
            return objc_getAssociatedObject(self, &Keys.originalDelegate) as? UICollectionViewDelegate
        }
        set {
            objc_setAssociatedObject(self, &Keys.originalDelegate, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}


// MARK: - Nested Types
//
private extension UICollectionView {

    enum Keys {
        static var ghostHandler = "ghostHandler"
        static var originalDataSource = "originalDataSource"
        static var originalDelegate = "originalDelegate"
    }
}

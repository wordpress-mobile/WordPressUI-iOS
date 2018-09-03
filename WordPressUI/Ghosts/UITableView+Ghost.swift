import Foundation
import UIKit



// MARK: - Skeleton UITableView Methods
//
extension UITableView {

    /// Displays Ghost Content with the specified Settings.
    ///
    open func displayGhostContent(using settings: GhostSettings) {
        guard isDisplayingGhostContent == false else {
            return
        }

        preserveInitialDelegates()
        setupGhostHandler(using: settings)

        reloadData()
    }

    /// Nukes the Ghost Style.
    ///
    open func removeGhostContent() {
        guard isDisplayingGhostContent else {
            return
        }

        restoreInitialDelegates()
        resetAssociatedReferences()
        removeGhostLayers()

        reloadData()
    }

    /// Indicates if the receiver is wired up to display Ghost Content.
    ///
    open var isDisplayingGhostContent: Bool {
        return ghostHandler != nil
    }
}


// MARK: - Private Methods
//
private extension UITableView {

    /// Sets up an internal (private) instance of GhostTableViewHandler.
    ///
    func setupGhostHandler(using settings: GhostSettings) {
        let handler = GhostTableViewHandler(using: settings)
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
private extension UITableView {

    /// Reference to the GhostHandler.
    ///
    var ghostHandler: GhostTableViewHandler? {
        get {
            return objc_getAssociatedObject(self, &Keys.ghostHandler) as? GhostTableViewHandler
        }
        set {
            objc_setAssociatedObject(self, &Keys.ghostHandler, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    /// UITableViewDataSource state, previous to mapping the GhostHandler.
    ///
    var initialDataSource: UITableViewDataSource? {
        get {
            return objc_getAssociatedObject(self, &Keys.originalDataSource) as? UITableViewDataSource
        }
        set {
            objc_setAssociatedObject(self, &Keys.originalDataSource, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    /// UITableViewDelegate state, previous to mapping the GhostHandler.
    ///
    var initialDelegate: UITableViewDelegate? {
        get {
            return objc_getAssociatedObject(self, &Keys.originalDelegate) as? UITableViewDelegate
        }
        set {
            objc_setAssociatedObject(self, &Keys.originalDelegate, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}


// MARK: - Nested Types
//
private extension UITableView {

    enum Keys {
        static var ghostHandler = "ghostHandler"
        static var originalDataSource = "originalDataSource"
        static var originalDelegate = "originalDelegate"
    }
}

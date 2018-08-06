import Foundation


extension UIViewController {
    /// Determines if the current ViewController's View is visible and onscreen
    ///
    public func isViewOnScreen() -> Bool {
        let visibleAsRoot       = view.window?.rootViewController == self
        let visibleAsTopOnStack = navigationController?.topViewController == self && view.window != nil
        let visibleAsPresented  = view.window?.rootViewController?.presentedViewController == self

        return visibleAsRoot || visibleAsTopOnStack || visibleAsPresented
    }

    /// Determines if the current ViewController's View is horizontally Compact
    ///
    public func hasHorizontallyCompactView() -> Bool {
        return traitCollection.horizontalSizeClass == .compact
    }

    /// Determines if the horizontal size class is specified or not.
    ///
    public func isHorizontalSizeClassUnspecified() -> Bool {
        return traitCollection.horizontalSizeClass == .unspecified
    }

    /// Determines if the current ViewController is being presented modally
    ///
    @objc public func isModal() -> Bool {
        if self.presentingViewController?.presentedViewController == self {
            return true
        } else if let navigationController = self.navigationController {
            if navigationController.presentingViewController != nil &&
                navigationController.presentingViewController?.presentedViewController == navigationController &&
                navigationController.childViewControllers.first == self {
                return true
            }
        }
        return false
    }

    /// Returns the view controller at the top of the view hierarchy (AKA leaf).
    ///
    @objc public var topmostPresentedViewController: UIViewController {
        var controller = self
        while let presented = controller.presentedViewController {
            controller = presented
        }
        return controller
    }
}

public extension UIViewController {

    /// This method adds a `UIViewController` as a childViewController,
    /// and calls the appropriate lifecycle methods.
    ///
    /// - Parameter childViewController: The childViewController to add to the view.
    func add(childViewController: UIViewController) {
        addChildViewController(childViewController)
        view.addSubview(childViewController.view)
        childViewController.didMove(toParentViewController: self)
    }

    /// This method adds a `UIViewController` as a childViewController,
    /// and calls the appropriate lifecycle methods.
    ///
    /// - Parameter childViewController: The childViewController to add to the view.
    /// - Parameter container: The view in the parent view controller that will contain the new vc.
    func add(childViewController: UIViewController, container: UIView) {
        addChildViewController(childViewController)
        container.addSubview(childViewController.view)
        childViewController.didMove(toParentViewController: self)
    }

    /// This method inserts a `UIViewController` as a childViewController below a subview,
    /// and calls the appropriate lifecycle methods.
    ///
    /// - Parameters:
    ///   childViewController: The childViewController to insert into the view.
    ///   - index: The subview to insert the childViewController below.
    func insert(childViewController: UIViewController, belowSubview subview: UIView) {
        addChildViewController(childViewController)
        view.insertSubview(childViewController.view, belowSubview: subview)
        childViewController.didMove(toParentViewController: self)
    }

    /// This method inserts a `UIViewController` as a childViewController above a subview,
    /// and calls the appropriate lifecycle methods.
    ///
    /// - Parameters:
    ///   childViewController: The childViewController to insert into the view.
    ///   - index: The subview to insert the childViewController above.
    func insert(childViewController: UIViewController, aboveSubview subview: UIView) {
        addChildViewController(childViewController)
        view.insertSubview(childViewController.view, aboveSubview: subview)
        childViewController.didMove(toParentViewController: self)
    }

    /// This function removes a childViewController from it's parent,
    /// and calls the appropriate lifecycle methods.
    func removeFromParent() {
        willMove(toParentViewController: nil)
        view.removeFromSuperview()
        removeFromParentViewController()
    }
}

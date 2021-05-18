import UIKit

public enum DrawerPosition {
    case expanded
    case collapsed
    case closed
    case hidden
}

public enum DrawerHeight {
    // The maximum height for the screen
    case maxHeight

    // Height is based on the specified margin from the top of the screen
    case topMargin(CGFloat)

    // Height will be equal to the the content height value. A height of 0 will use the calculated height.
    case contentHeight(CGFloat)

    // Height in the hidden state will be equal the screens height
    case hidden

    // Calculate the intrisinc content based on the View Controller
    case intrinsicHeight
}

public enum DrawerWidth {
    // Fills the whole screen width
    case maxWidth

    // When in compact mode, fills a percentage of the screen
    case percentage(CGFloat)

    // Width will be equal to the the content height value
    case contentWidth(CGFloat)
}

public protocol DrawerPresentable: AnyObject {
    /// The height of the drawer when it's in the expanded position
    var expandedHeight: DrawerHeight { get }

    /// The height of the drawer when it's in the collapsed position
    var collapsedHeight: DrawerHeight { get }

    /// The width of the Drawer in compact screen
    var compactWidth: DrawerWidth { get }

    /// Whether or not the user is allowed to swipe to switch between the expanded and collapsed position
    var allowsUserTransition: Bool { get }

    /// Whether or not the user is allowed to drag to dismiss the drawer
    var allowsDragToDismiss: Bool { get }

    /// Whether or not the user is allowed to tap outside the view to dismiss the drawer
    var allowsTapToDismiss: Bool { get }

    /// A scroll view that should have its insets adjusted when the drawer is expanded/collapsed
    var scrollableView: UIScrollView? { get }

    func handleDismiss()
}

private enum Constants {
    static let transitionDuration: TimeInterval = 0.5

    static let flickVelocity: CGFloat = 300
    static let bounceAmount: CGFloat = 0.01

    enum Defaults {
        static let expandedHeight: DrawerHeight = .topMargin(20)
        static let collapsedHeight: DrawerHeight = .contentHeight(0)
        static let compactWidth: DrawerWidth = .percentage(0.66)

        static let allowsUserTransition: Bool = true
        static let allowsTapToDismiss: Bool = true
        static let allowsDragToDismiss: Bool = true
    }
}

public typealias DrawerPresentableViewController = DrawerPresentable & UIViewController

public extension DrawerPresentable where Self: UIViewController {
    // Default values
    var allowsUserTransition: Bool {
        return Constants.Defaults.allowsUserTransition
    }

    var expandedHeight: DrawerHeight {
        return Constants.Defaults.expandedHeight
    }

    var collapsedHeight: DrawerHeight {
        return Constants.Defaults.collapsedHeight
    }

    var compactWidth: DrawerWidth {
        return Constants.Defaults.compactWidth
    }

    var scrollableView: UIScrollView? {
        return nil
    }

    var allowsDragToDismiss: Bool {
        return Constants.Defaults.allowsDragToDismiss
    }

    var allowsTapToDismiss: Bool {
        return Constants.Defaults.allowsTapToDismiss
    }

    // Helpers

    /// Try to determine the correct DrawerPresentationController to use

    /// Returns the `DrawerPresentationController` for a view controller if there is one
    /// This tries to determine the correct one to use in the following order:
    /// - The view controller
    /// - The navController
    /// - The navController parentViewController
    /// - The views parentViewController
    var presentedVC: DrawerPresentationController? {
        let presentationController = self.presentationController as? DrawerPresentationController
        let navigationPresentationController = navigationController?.presentationController as? DrawerPresentationController
        let navParentPresetationController = navigationController?.parent?.presentationController as? DrawerPresentationController
        let parentPresentationController = parent?.presentationController as? DrawerPresentationController

        return presentationController ?? navigationPresentationController ?? navParentPresetationController ?? parentPresentationController
    }

    func handleDismiss() { }
}

public class DrawerPresentationController: FancyAlertPresentationController {
    override public var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = self.containerView else {
            return .zero
        }

        var frame = containerView.frame
        let y = collapsedYPosition
        var width: CGFloat = containerView.bounds.width - (containerView.safeAreaInsets.left + containerView.safeAreaInsets.right)

        frame.origin.y = y

        /// If we're in a compact vertical size class, constrain the width a bit more so it doesn't get overly wide.
        if let widthForCompactSizeClass = presentableViewController?.compactWidth,
            traitCollection.verticalSizeClass == .compact {

            switch widthForCompactSizeClass {
            case .percentage(let percentage):
                width = width * percentage
            case .contentWidth(let givenWidth):
                width = givenWidth
            case .maxWidth:
                break
            }
        }
        frame.size.width = width

        /// If we constrain the width, this centers the view by applying the appropriate insets based on width
        frame.origin.x = ((containerView.bounds.width - width) / 2)

        return frame
    }

    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { _ in
            self.presentedView?.frame = self.frameOfPresentedViewInContainerView
            self.transition(to: self.currentPosition)
        }, completion: nil)
        super.viewWillTransition(to: size, with: coordinator)
    }

    /// Returns the current position of the drawer
    public var currentPosition: DrawerPosition = .collapsed

    /// Returns the Y position of the drawer
    public var yPosition: CGFloat? {
        return presentedView?.frame.origin.y
    }

    /// Animates between the drawer positions
    /// - Parameter position: The position to animate to
    public func transition(to position: DrawerPosition) {
        currentPosition = position

        if position == .closed {
            dismiss()
            return
        }

        var margin: CGFloat = 0

        switch position {
        case .expanded:
            margin = expandedYPosition

        case .collapsed:
            margin = collapsedYPosition

        case .hidden:
            margin = hiddenYPosition

        default:
            margin = 0
        }

        setTopMargin(margin)
    }

    @objc func dismiss() {
        presentedViewController.dismiss(animated: true, completion: nil)
    }

    public override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()

        configureScrollViewInsets()
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        transition(to: currentPosition)
    }

    public override func presentationTransitionDidEnd(_ completed: Bool) {
        super.presentationTransitionDidEnd(completed)

        configureScrollViewInsets()
    }


    // MARK: - Internal Positions
    // Helpers to calculate the Y positions for the drawer positions

    private var closedPosition: CGFloat {
        guard let presentedView = self.presentedView else {
            return 0
        }

        return presentedView.bounds.height
    }

    private var collapsedYPosition: CGFloat {
        let height = presentableViewController?.collapsedHeight ?? Constants.Defaults.collapsedHeight

        return topMargin(with: height)
    }

    private var expandedYPosition: CGFloat {
        let height = presentableViewController?.expandedHeight ?? Constants.Defaults.expandedHeight

        return topMargin(with: height)
    }

    private var hiddenYPosition: CGFloat {
        return topMargin(with: .hidden)
    }

    /// Calculates the Y position for the view based on a DrawerHeight enum
    /// - Parameter drawerHeight: The drawer height to calculate
    private func topMargin(with drawerHeight: DrawerHeight) -> CGFloat {
        var topMargin: CGFloat

        switch drawerHeight {
        case .contentHeight(let height):
            topMargin = calculatedTopMargin(for: height)

        case .topMargin(let margin):
            topMargin = safeAreaInsets.top + margin

        case .maxHeight:
            topMargin = safeAreaInsets.top

        case .intrinsicHeight:
            // Force a layout to make sure we get the correct size from the views
            presentedViewController.view.layoutIfNeeded()

            let height = presentedViewController.preferredContentSize.height
            topMargin = calculatedTopMargin(for: height)

        case .hidden:
            topMargin = UIScreen.main.bounds.height
        }

        return topMargin
    }

    // MARK: - Gestures
    private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.dismiss(_:)))
        gesture.delegate = self
        return gesture
    }()

    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.pan(_:)))
        panGesture.delegate = self
        return panGesture
    }()

    override public func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()

        addGestures()
        observe(scrollView: presentableViewController?.scrollableView)
    }
    
    /// Represents whether the view is animating to a new position
    private var isPresentedViewAnimating = false
    
    /// Whether or not the presented view is anchored to the top of the screen
    private var isPresentedViewAnchored: Bool {
        if !isPresentedViewAnimating
                && (presentedView?.frame.origin.y.rounded() ?? 0) <= expandedYPosition.rounded() {
            return true
        }

        return false
    }

    private var dragStartPoint: CGPoint?
    
    /// Stores the current `contentOffset.y` for `presentableViewController.scrollableView`
    /// See `haltScrolling` and `trackScrolling` for more information.
    private var scrollViewYOffset: CGFloat = 0.0
        
    /// An observer of the content offset for `presentableViewController.scrollableView`
    private var scrollObserver: NSKeyValueObservation?
    
    deinit {
        scrollObserver?.invalidate()
    }
}

// MARK: - Dragging
private extension DrawerPresentationController {
    
    private func addGestures() {
        guard
            let presentedView = self.presentedView,
            let containerView = self.containerView
            else { return }

        presentedView.addGestureRecognizer(panGestureRecognizer)
        containerView.addGestureRecognizer(tapGestureRecognizer)
    }

    /// Dismiss action for the tap gesture
    /// Will prevent dismissal if the `allowsTapToDismiss` is false
    /// - Parameter gesture: The tap gesture
    @objc func dismiss(_ gesture: UIPanGestureRecognizer) {
        let canDismiss = presentableViewController?.allowsTapToDismiss ?? Constants.Defaults.allowsTapToDismiss

        guard canDismiss else {
            return
        }

        dismiss()
    }

    @objc func pan(_ gesture: UIPanGestureRecognizer) {
        guard let presentedView = self.presentedView else { return }
        
        let isScrolling = presentableViewController?.scrollableView?.isScrolling == true
        
        guard (presentableViewController?.scrollableView?.contentOffset.y ?? 0) <= 0 || isScrolling == false else { return }
        
        /// Ignore the animation once panning begins so we can immediately interact
        isPresentedViewAnimating = false

        let translation = gesture.translation(in: presentedView)
        let allowsUserTransition = presentableViewController?.allowsUserTransition ?? Constants.Defaults.allowsUserTransition
        let allowDragToDismiss = presentableViewController?.allowsDragToDismiss ?? Constants.Defaults.allowsDragToDismiss

        switch gesture.state {
        case .began:
            dragStartPoint = presentedView.frame.origin

        case .changed:
            let startY = dragStartPoint?.y ?? 0
            var yTranslation = translation.y
            
            /// Slows the deceleration rate
            if isScrolling && presentedView.frame.origin.y < expandedYPosition {
                yTranslation /= 2.0
            }

            if !allowsUserTransition || !allowDragToDismiss {
                let maxBounce: CGFloat = (startY * Constants.bounceAmount)

                if yTranslation < 0 {
                    yTranslation = max(yTranslation, maxBounce * -1)
                } else {
                    if !allowDragToDismiss {
                        yTranslation = min(yTranslation, maxBounce)
                    }
                }
            }

            let maxY = topMargin(with: .maxHeight)
            var yPosition = startY + yTranslation
            if isScrolling {
                /// During scrolling, ensure yPosition doesn't extend past the expanded position
                yPosition = max(yPosition, expandedYPosition)
            }
            
            let newMargin = max(yPosition, maxY)
            setTopMargin(newMargin, animated: false)

        case .ended:
            /// Helper closure to prevent user transition/dismiss
            let transition: (DrawerPosition) -> () = { pos in
                if allowsUserTransition || pos == .closed && allowDragToDismiss {
                    self.transition(to: pos)
                } else {
                    //Reset to the original position
                    self.transition(to: self.currentPosition)
                }
            }

            let velocity = gesture.velocity(in: presentedView).y
            let startY = dragStartPoint?.y ?? 0

            let currentPosition = (startY + translation.y)
            let position = closestPosition(for: currentPosition)

            // Determine how to handle flicking of the view
            if (abs(velocity) - Constants.flickVelocity) > 0 {
                //Flick up
                if velocity < 0 {
                    transition(.expanded)
                }
                else {
                    if position == .expanded {
                        transition(.collapsed)
                    } else {
                        transition(.closed)
                    }
                }

                return
            }

            transition(position)

            dragStartPoint = nil

        default:
            return
        }
    }
}

// MARK: - Scrolling
private extension DrawerPresentationController {
    
    /// Adds an observer for the scroll view's content offset.
    /// Track scrolling without overriding the `scrollView` delegate
    /// - Parameter scrollView: The scroll view whose content offset will be tracked.
    func observe(scrollView: UIScrollView?) {
        scrollObserver?.invalidate()
        scrollObserver = scrollView?.observe(\.contentOffset, options: .old) { [weak self] scrollView, change in

            /// In case there are two containerViews in the same presentation
            guard self?.containerView != nil
                else { return }

            self?.didPan(on: scrollView, change: change)
        }
    }
    
    /// Handles scroll view content offset changes
    /// - Parameters:
    ///   - scrollView: The scroll view whose content offset is changing.
    ///   - change: The change representing the old and new content offsets.
    func didPan(on scrollView: UIScrollView, change: NSKeyValueObservedChange<CGPoint>) {
        
        guard
            !presentedViewController.isBeingDismissed,
            !presentedViewController.isBeingPresented
            else { return }

        if !isPresentedViewAnchored && scrollView.contentOffset.y > 0 {

            /// Halts scrolling when scrolling down from expanded or up from compact
            haltScrolling(scrollView)

        } else if scrollView.isScrolling {

            if isPresentedViewAnchored {
                /// Allow normal scrolling (with tracking)
                trackScrolling(scrollView)
            } else {
                /// Halts scrolling when panning down from expanded
                haltScrolling(scrollView)
            }

        } else {
            /// Allow normal scrolling (with tracking)
            trackScrolling(scrollView)
        }
    }
    
    /// Stops scrolling behavior on `scrollView` and anchors to `scrollViewYOffset`.
    /// - Parameter scrollView: The scroll view to stop and anchor anchor
    private func haltScrolling(_ scrollView: UIScrollView) {
        // Only halt the scrolling if we haven't halted it before
        guard scrollView.showsVerticalScrollIndicator else {
            return
        }

        scrollView.setContentOffset(CGPoint(x: 0, y: scrollViewYOffset), animated: false)
        scrollView.showsVerticalScrollIndicator = false
    }
    
    /// Tracks and saves the y offset of `scrollView` in `scrollViewYOffset`.
    /// Used later by `haltScrolling` to adjust the scroll view to `scrollViewYOffset` to give the appearance of the sticking position.
    /// - Parameter scrollView: The scroll view to track.
    private func trackScrolling(_ scrollView: UIScrollView) {
        scrollViewYOffset = max(scrollView.contentOffset.y, 0)
        scrollView.showsVerticalScrollIndicator = true
    }
}

private extension UIScrollView {
    /// A flag to determine if a scroll view is scrolling
    var isScrolling: Bool {
        return isDragging && !isDecelerating || isTracking
    }
}

extension DrawerPresentationController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        guard tapGestureRecognizer == gestureRecognizer else { return true }
        
        /// Shouldn't happen; should always have container & presented view when tapped
        guard
            let containerView = containerView,
            let presentedView = presentedView,
            currentPosition != .hidden
        else {
            return false
        }

        let touchPoint = touch.location(in: containerView)
        let isInPresentedView = presentedView.frame.contains(touchPoint)

        /// Do not accept the touch if inside of the presented view
        return (gestureRecognizer == tapGestureRecognizer) && isInPresentedView == false
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return otherGestureRecognizer.view == presentableViewController?.scrollableView
    }
}

// MARK: - Private: Helpers
private extension DrawerPresentationController {

    private func configureScrollViewInsets() {
        guard
            let scrollView = presentableViewController?.scrollableView,
            let presentedView = self.presentedView,
            let presentingView = presentingViewController.view
            else { return }


        let bottom = presentingView.safeAreaInsets.bottom
        let margin = presentedView.frame.origin.y + bottom

        scrollView.contentInset.bottom = margin
    }

    private var presentableViewController: DrawerPresentable? {
        return presentedViewController as? DrawerPresentable
    }

    private func calculatedTopMargin(for height: CGFloat) -> CGFloat {
        guard let containerView = self.containerView else {
            return 0
        }

        let bounds = containerView.bounds
        let margin = bounds.maxY - (safeAreaInsets.bottom + ((height > 0) ? height : (bounds.height * 0.5)))

        // Limit the max height
        return max(margin, safeAreaInsets.top)
    }

    private func setTopMargin(_ margin: CGFloat, animated: Bool = true) {
        guard let presentedView = self.presentedView else {
            return
        }

        var frame = presentedView.frame
        frame.origin.y = margin

        let animations = {
            presentedView.frame = frame

            self.configureScrollViewInsets()
        }

        if animated {
            animate(animations)
        } else {
            animations()
        }
    }

    private var safeAreaInsets: UIEdgeInsets {
        guard let rootViewController = self.rootViewController else {
            return .zero
        }

        return rootViewController.view.safeAreaInsets
    }

    func closestPosition(for yPosition: CGFloat) -> DrawerPosition {
        let positions = [closedPosition, collapsedYPosition, expandedYPosition]
        let closestVal = positions.min(by: { abs(yPosition - $0) < abs(yPosition - $1) }) ?? yPosition

        var returnPosition: DrawerPosition = .closed

        if closestVal == expandedYPosition {
            returnPosition = .expanded
        } else if closestVal == collapsedYPosition {
            returnPosition = .collapsed
        }

        return returnPosition
    }

    private func animate(_ animations: @escaping () -> Void) {
        isPresentedViewAnimating = true
        UIView.animate(withDuration: Constants.transitionDuration,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0,
                       options: [.curveEaseInOut, .allowUserInteraction],
                       animations: animations) { [weak self] completed in
            self?.isPresentedViewAnimating = false
        }
    }

    private var rootViewController: UIViewController? {
        guard let application = UIApplication.value(forKeyPath: #keyPath(UIApplication.shared)) as? UIApplication
            else { return nil }

        return application.keyWindow?.rootViewController
    }
}

import Foundation
import UIKit

public class BottomSheetAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    public enum TransitionType {
        case presenting
        case dismissing
    }

    private let transitionType: TransitionType

    public init(transitionType: TransitionType) {
        self.transitionType = transitionType
        super.init()
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toView: UIView = transitionContext.view(forKey: .to) ?? transitionContext.viewController(forKey: .to)?.view,
              let fromView: UIView = transitionContext.view(forKey: .from) ?? transitionContext.viewController(forKey: .from)?.view else {
            return
        }
        let inView = transitionContext.containerView
        let presentedViewController = transitionContext.viewController(forKey: .to)

        let animationBlock: () -> Void
        switch transitionType {
        case .presenting:
            let presentedFrame = presentedViewController?.presentationController?.frameOfPresentedViewInContainerView ?? .zero
            toView.frame = presentedFrame.offsetBy(dx: 0, dy: inView.frame.maxY)
            inView.addSubview(toView)
            animationBlock = {
                toView.frame = presentedFrame
            }
        case .dismissing:
            let dismissingFrame = fromView.frame.offsetBy(dx: 0, dy: fromView.bounds.height)
            animationBlock = {
                fromView.frame = dismissingFrame
            }
        }

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: animationBlock, completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
}

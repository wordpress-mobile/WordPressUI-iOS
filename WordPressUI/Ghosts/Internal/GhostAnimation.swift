import Foundation
import QuartzCore
import UIKit


/// GhostAnimation: Animates a CALayer with a "Beating" animation, that interpolates from Color A to Color B.
///
class GhostAnimation: CABasicAnimation {

    /// Default Animation Key
    ///
    static let defaultKey = "SkeletonAnimationKey"


    /// Designated Initializer
    ///
    init(startColor: UIColor, endColor: UIColor, loopDuration: TimeInterval) {
        super.init()

        keyPath = #keyPath(CALayer.backgroundColor)
        fromValue = startColor
        toValue = endColor
        duration = loopDuration
        timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        repeatCount = .infinity
        autoreverses = true
    }

    /// Required Initializer
    ///
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}

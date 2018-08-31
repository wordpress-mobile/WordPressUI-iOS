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
    override init() {
        super.init()

        keyPath = #keyPath(CALayer.backgroundColor)
        fromValue = GhostSettings.beatStartColor.cgColor
        toValue = GhostSettings.beatEndColor.cgColor
        duration = GhostSettings.beatDuration
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

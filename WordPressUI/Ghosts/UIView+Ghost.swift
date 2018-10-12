import Foundation
import UIKit


// MARK: - Ghost Animations API
//
extension UIView {

    /// Applies Ghost Layers and starts the Beating Animation.
    ///
    open func startGhostAnimation(style: GhostStyle = .default) {
        insertGhostLayers { layer in
            layer.backgroundColor = style.beatStartColor.cgColor
            layer.startAnimating(fromColor: style.beatStartColor, toColor: style.beatEndColor, duration: style.beatDuration)
        }
    }

    /// Removes the Ghost Layers.
    ///
    open func stopGhostAnimation() {
        enumerateGhostLayers { layer in
            layer.removeFromSuperlayer()
        }
    }
}

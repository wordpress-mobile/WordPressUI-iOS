import Foundation
import UIKit


// MARK: - Ghost Animations API
//
extension UIView {

    /// Applies Ghost Layers and starts the Beating Animation.
    ///
    open func startGhostAnimation(style: GhostStyle = .default) {
        insertGhostLayers { layer in
            layer.startAnimating(fromColor: style.beatStartColor, toColor: style.beatEndColor, duration: style.beatDuration)
        }
    }

    /// Loops thru all of the Ghost Layers (that are already there) and restarts the Beating Animation.
    /// If there were no previous Ghost Layers inserted, this method won't do anything.
    ///
    open func restartGhostAnimation(style: GhostStyle = .default) {
        enumerateGhostLayers { layer in
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

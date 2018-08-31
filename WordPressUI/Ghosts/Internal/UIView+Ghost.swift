import Foundation
import UIKit


/// UIView: Skeletonizer Public API
///
extension UIView {

    /// Applies a GhostLayer on each one of the receiver's Leaf Views (if needed).
    ///
    func insertGhostLayers(callback: (GhostLayer) -> Void) {
        layoutIfNeeded()

        enumerateLeafViews { leafView in
            guard leafView.containsGhostLayer == false else {
                return
            }

            let layer = GhostLayer()
            layer.insert(into: leafView)
            callback(layer)
        }
    }

    /// Removes all of the GhostLayer(s) from the Leaf Views.
    ///
    func removeGhostLayers() {
        enumerateGhostLayers { skeletonLayer in
            skeletonLayer.removeFromSuperlayer()
        }
    }

    /// Enumerates all of the receiver's GhostLayer(s).
    ///
    func enumerateGhostLayers(callback: (GhostLayer) -> Void) {
        enumerateLeafViews { leafView in
            let targetLayer = leafView.layer.sublayers?.first(where: { $0 is GhostLayer })
            guard let skeletonLayer = targetLayer as? GhostLayer else {
                return
            }

            callback(skeletonLayer)
        }
    }
}


/// Private Methods
///
private extension UIView {

    /// Indicates if the receiver contains a GhostLayer.
    ///
    var containsGhostLayer: Bool {
        let output = layer.sublayers?.contains { $0 is GhostLayer }
        return output ?? false
    }

    /// Enumerates all of the receiver's Leaf Views.
    ///
    func enumerateLeafViews(callback: (UIView) -> ()) {
        guard !subviews.isEmpty else {
            callback(self)
            return
        }

        for subview in subviews {
            subview.enumerateLeafViews(callback: callback)
        }
    }
}
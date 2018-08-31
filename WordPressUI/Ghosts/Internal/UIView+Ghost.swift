import Foundation
import UIKit


/// UIView: Skeletonizer Public API
///
extension UIView {

    /// Applies a GhostLayer on each one of the receiver's Leaf Views and starts animating them immediately.
    /// Note: No more than one GhostLayer is allowed, per leafView.
    ///
    func insertAnimatedGhostLayers() {
        layoutIfNeeded()

        enumerateLeafViews { leafView in
            guard leafView.containsGhostLayer() == false else {
                return
            }

            let layer = GhostLayer()
            layer.insert(into: leafView)
            layer.startAnimating()
        }
    }

    /// Starts animating all of the GhostLayer(s).
    ///
    func animateGhostLayers() {
        enumerateGhostLayers { layer in
            layer.startAnimating()
        }
    }

    /// Removes all of the GhostLayer(s) from the Leaf Views.
    ///
    func removeGhostLayers() {
        enumerateGhostLayers { skeletonLayer in
            skeletonLayer.removeFromSuperlayer()
        }
    }
}


/// Private Methods
///
private extension UIView {

    /// Indicates if the receiver contains a GhostLayer.
    ///
    func containsGhostLayer() -> Bool {
        let output = layer.sublayers?.contains { $0 is GhostLayer }
        return output ?? false
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

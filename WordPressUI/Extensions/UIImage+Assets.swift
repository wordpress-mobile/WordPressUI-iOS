import Foundation


// MARK: - Named Assets
//
extension UIImage {

    /// Returns the Default Site Icon Placeholder Image.
    ///
    @objc
    public static var siteIconPlaceholderImage: UIImage {
        return UIImage(named: "blavatar", in: bundle, compatibleWith: nil)!
    }


    /// Returns the Default Gravatar Placeholder Image.
    ///
    @objc
    public static var gravatarPlaceholderImage: UIImage {
        return UIImage(named: "gravatar", in: bundle, compatibleWith: nil)!
    }

    /// Returns the Link Image.
    ///
    @objc
    public static var linkFieldImage: UIImage {
        return UIImage(named: "icon-url-field", in: bundle, compatibleWith: nil)!
    }

    /// Returns WordPressUI's Bundle
    ///
    private static var bundle: Bundle {
        return Bundle(for: UIKitConstants.self)
    }

    /// Renders the Background Image with the specified Background + Size + Radius + Insets parameters.
    ///
    public class func renderBackgroundImage(fill: UIColor,
                               border: UIColor,
                               size: CGSize = DefaultRenderMetrics.backgroundImageSize,
                               cornerRadius: CGFloat = DefaultRenderMetrics.backgroundCornerRadius,
                               capInsets: UIEdgeInsets = DefaultRenderMetrics.backgroundCapInsets,
                               shadowOffset: CGSize = DefaultRenderMetrics.backgroundShadowOffset,
                               shadowBlurRadius: CGFloat = DefaultRenderMetrics.backgroundShadowBlurRadius) -> UIImage {

        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in

            let lineWidthInPixels = 1 / UIScreen.main.scale
            let cgContext = context.cgContext

            /// Apply a 1px inset to the bounds, for our bezier (so that the border doesn't fall outside, capicci?)
            ///
            var bounds = renderer.format.bounds
            bounds.origin.x += lineWidthInPixels
            bounds.origin.y += lineWidthInPixels
            bounds.size.height -= lineWidthInPixels * 2 + shadowOffset.height
            bounds.size.width -= lineWidthInPixels * 2 + shadowOffset.width

            let path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)

            /// Draw: Background + Shadow
            cgContext.saveGState()
            cgContext.setShadow(offset: shadowOffset, blur: shadowBlurRadius, color: border.cgColor)
            fill.setFill()

            path.fill()

            cgContext.restoreGState()

            /// Draw: Border!
            border.setStroke()
            path.stroke()
        }

        return image.resizableImage(withCapInsets: capInsets)
    }

    /// Default Metrics
    ///
    public struct DefaultRenderMetrics {
        public static let backgroundImageSize = CGSize(width: 44, height: 44)
        public static let backgroundCornerRadius = CGFloat(8)
        public static let backgroundCapInsets = UIEdgeInsets(top: 18, left: 18, bottom: 18, right: 18)
        public static let backgroundShadowOffset = CGSize(width: 0, height: 2)
        public static let backgroundShadowBlurRadius = CGFloat(0)
        public static let contentInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
    }
}

//
//  UIImage+Assets.swift
//
//
//  Created by Andrew Montgomery on 1/25/24.
//

import Foundation
import UIKit

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
    
    /// Returns Gravatar's Bundle
    ///
    private static var bundle: Bundle {
        return Bundle.gravatarBundle
    }
}

extension Bundle {
    @objc public class var gravatarBundle: Bundle {
#if SWIFT_PACKAGE
        return Bundle.module
#else
        let defaultBundle = Bundle(for: FancyAlertViewController.self)
        // If installed with CocoaPods, resources will be in WordPressUIResources.bundle
        if let bundleUrl = defaultBundle.url(forResource: "WordPressUIResources", withExtension: "bundle"),
           let resourceBundle = Bundle(url: bundleUrl) {
            return resourceBundle
        }
        // Otherwise, the default bundle is used for resources
        return defaultBundle
#endif
    }
}

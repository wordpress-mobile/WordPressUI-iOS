import Foundation

extension Bundle {
    @objc public class var wordPressUIBundle: Bundle {
        let defaultBundle = Bundle(for: FancyAlertViewController.self)
        if let resourceBundle = Bundle(url: defaultBundle.bundleURL.appendingPathComponent("WordPressUIResources.bundle")) {
        // If installed with CocoaPods, resources will be in WordPressUIResources.bundle
            return resourceBundle
        }
        // Otherwise, the default bundle is used for resources
        return defaultBundle
    }
}

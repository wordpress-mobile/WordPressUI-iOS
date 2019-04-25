import Foundation

extension Bundle {
    @objc public class var wordPressUIBundle: Bundle {
        let defaultBundle = Bundle(for: FancyAlertViewController.self)
        // If installed with CocoaPods, resources will be in WordPressUI.bundle
        if let bundleURL = defaultBundle.resourceURL,
            let resourceBundle = Bundle(url: bundleURL.appendingPathComponent("WordPressUI.bundle")) {
            return resourceBundle
        }
        // Otherwise, the default bundle is used for resources
        return defaultBundle
    }
}

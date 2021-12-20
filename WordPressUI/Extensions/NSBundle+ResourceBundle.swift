import Foundation

extension Bundle {
    @objc public class var wordPressUIBundle: Bundle {
        let defaultBundle = Bundle(for: FancyAlertViewController.self)
        // If installed with CocoaPods, resources will be in WordPressUIResources.bundle
        if let bundleUrl = defaultBundle.url(forResource: "WordPressUIResources", withExtension: "bundle"),
           let resourceBundle = Bundle(url: bundleUrl) {
            return resourceBundle
        }
        // Otherwise, the default bundle is used for resources
        return defaultBundle
    }
}

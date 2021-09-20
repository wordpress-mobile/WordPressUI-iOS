import Foundation

/// Wrapper class used to ensure removeObserver is called
private class GravatarNotificationWrapper {
    let observer: NSObjectProtocol

    init(observer: NSObjectProtocol) {
        self.observer = observer
    }

    deinit {
        NotificationCenter.default.removeObserver(observer)
    }
}

/// UIImageView Helper Methods that allow us to download a Gravatar, given the User's Email
///
extension UIImageView {

    /// Helper Enum that specifies all of the available Gravatar Image Ratings
    /// TODO: Convert into a pure Swift String Enum. It's done this way to maintain ObjC Compatibility
    ///
    @objc
    public enum GravatarRatings: Int {
        case g
        case pg
        case r
        case x
        case `default`

        func stringValue() -> String {
            switch self {
            case .default:
                fallthrough
            case .g:
                return "g"
            case .pg:
                return "pg"
            case .r:
                return "r"
            case .x:
                return "x"
            }
        }
    }

    /// Downloads and sets the User's Gravatar, given his email.
    /// TODO: This is a convenience method. Please, remove once all of the code has been migrated over to Swift.
    ///
    /// - Parameters:
    ///     - email: the user's email
    ///     - rating: expected image rating
    ///
    @objc
    public func downloadGravatarWithEmail(_ email: String, rating: GravatarRatings) {
        downloadGravatarWithEmail(email, rating: rating, placeholderImage: .gravatarPlaceholderImage)
    }

    /// Downloads and sets the User's Gravatar, given his email.
    ///
    /// - Parameters:
    ///     - email: the user's email
    ///     - rating: expected image rating
    ///     - placeholderImage: Image to be used as Placeholder
    ///
    @objc
    public func downloadGravatarWithEmail(_ email: String, rating: GravatarRatings = .default, placeholderImage: UIImage = .gravatarPlaceholderImage) {
        let gravatarURL = gravatarUrl(for: email, size: gravatarDefaultSize(), rating: rating)

        listenForGravatarChanges(forEmail: email)
        downloadImage(from: gravatarURL, placeholderImage: placeholderImage)
    }

    /// Configures the UIImageView to listen for changes to the gravatar it is displaying
    private func listenForGravatarChanges(forEmail trackedEmail: String) {        
        if let currentObersver = gravatarWrapper?.observer {
            NotificationCenter.default.removeObserver(currentObersver)
            gravatarWrapper = nil
        }

        let observer = NotificationCenter.default.addObserver(forName: .GravatarImageUpdateNotification, object: nil, queue: nil) { [weak self] (notification) in
            guard let userInfo = notification.userInfo,
                let email = userInfo[Defaults.emailKey] as? String,
                email == trackedEmail,
                let image = userInfo[Defaults.imageKey] as? UIImage else {
                    return
            }

            self?.image = image
        }
        gravatarWrapper = GravatarNotificationWrapper(observer: observer)
    }

    /// Stores the gravatar observer
    ///
    fileprivate var gravatarWrapper: GravatarNotificationWrapper? {
        get {
            return objc_getAssociatedObject(self, &Defaults.gravatarWrapperKey) as? GravatarNotificationWrapper
        }
        set {
            objc_setAssociatedObject(self, &Defaults.gravatarWrapperKey, newValue as AnyObject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /// Downloads the provided Gravatar.
    ///
    /// - Parameters:
    ///     - gravatar: the user's Gravatar
    ///     - placeholder: Image to be used as Placeholder
    ///     - animate: enable/disable fade in animation
    ///     - failure: Callback block to be invoked when an error occurs while fetching the Gravatar image
    ///
    public func downloadGravatar(_ gravatar: Gravatar?, placeholder: UIImage, animate: Bool, failure: ((Error?) -> ())? = nil) {
        guard let gravatar = gravatar else {
            self.image = placeholder
            return
        }

        // Starting with iOS 10, it seems `initWithCoder` uses a default size
        // of 1000x1000, which was messing with our size calculations for gravatars
        // on newly created table cells.
        // Calling `layoutIfNeeded()` forces UIKit to calculate the actual size.
        layoutIfNeeded()

        let size = Int(ceil(frame.width * UIScreen.main.scale))
        let url = gravatar.urlWithSize(size)

        self.downloadImage(from: url,
                           placeholderImage: placeholder,
                           success: { image in
                            guard image != self.image else {
                                return
                            }

                            self.image = image
                            if animate {
                                self.fadeInAnimation()
                            }
        }, failure: { error in
            failure?(error)
        })
    }


    /// Sets an Image Override in both, AFNetworking's Private Cache + NSURLCache
    ///
    /// - Parameters:
    ///   - image: new UIImage
    ///   - rating: rating for the new image.
    ///   - email: associated email of the new gravatar
    /// - Note: You may want to use `updateGravatar(image:, email:)` instead
    ///
    /// *WHY* is this required?. *WHY* life has to be so complicated?, is the universe against us?
    /// This has been implemented as a workaround. During Upload, we want any async calls made to the
    /// `downloadGravatar` API to return the "Fresh" image.
    ///
    /// Note II:
    /// We cannot just clear NSURLCache, since the helper that's supposed to do that, is broken since iOS 8.
    /// Ref: Ref: http://blog.airsource.co.uk/2014/10/11/nsurlcache-ios8-broken/
    ///
    /// P.s.:
    /// Hope buddah, and the code reviewer, can forgive me for this hack.
    ///
    @objc public func overrideGravatarImageCache(_ image: UIImage, rating: GravatarRatings, email: String) {
        guard let gravatarURL = gravatarUrl(for: email, size: gravatarDefaultSize(), rating: rating) else {
            return
        }

        listenForGravatarChanges(forEmail: email)
        overrideImageCache(for: gravatarURL, with: image)
    }

    /// Updates the gravatar image for the given email, and notifies all gravatar image views
    ///
    /// - Parameters:
    ///   - image: the new UIImage
    ///   - email: associated email of the new gravatar
    @objc public func updateGravatar(image: UIImage, email: String?) {
        self.image = image
        guard let email = email else {
            return
        }
        NotificationCenter.default.post(name: .GravatarImageUpdateNotification, object: self, userInfo: [Defaults.emailKey: email, Defaults.imageKey: image])
    }


    // MARK: - Private Helpers

    /// Returns the Gravatar URL, for a given email, with the specified size + rating.
    ///
    /// - Parameters:
    ///     - email: the user's email
    ///     - size: required download size
    ///     - rating: image rating filtering
    ///
    /// - Returns: Gravatar's URL
    ///
    private func gravatarUrl(for email: String, size: Int, rating: GravatarRatings) -> URL? {
        let hash = gravatarHash(of: email)
        let targetURL = String(format: "%@/%@?d=404&s=%d&r=%@", Defaults.baseURL, hash, size, rating.stringValue())
        return URL(string: targetURL)
    }

    /// Returns the gravatar hash of an email
    ///
    /// - Parameter email: the email associated with the gravatar
    /// - Returns: hashed email
    ///
    /// This really ought to be in a different place, like Gravatar.swift, but there's
    /// lots of duplication around gravatars -nh
    private func gravatarHash(of email: String) -> String {
        return email
            .lowercased()
            .trimmingCharacters(in: .whitespaces)
            .md5Hash()
    }

    /// Returns the required gravatar size. If the current view's size is zero, falls back to the default size.
    ///
    private func gravatarDefaultSize() -> Int {
        guard bounds.size.equalTo(.zero) == false else {
            return Defaults.imageSize
        }

        let targetSize = max(bounds.width, bounds.height) * UIScreen.main.scale
        return Int(targetSize)
    }

    /// Private helper structure: contains the default Gravatar parameters
    ///
    private struct Defaults {
        static let imageSize = 80
        static let baseURL = "https://gravatar.com/avatar"
        static var gravatarWrapperKey = "gravatarWrapperKey"
        static let emailKey = "email"
        static let imageKey = "image"
    }
}

extension NSNotification.Name {
    static let GravatarImageUpdateNotification = NSNotification.Name(rawValue: "GravatarImageUpdateNotification")
}

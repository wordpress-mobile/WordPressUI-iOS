import Foundation
import UIKit
import Gravatar
import enum Gravatar.Rating

public typealias ImageRating = Rating

#if SWIFT_PACKAGE
import WordPressUIObjC
#endif

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

// TODO: Convenience intermediate enum for Objc compatibility. Remove when Objc compatibility is not needed.
@objc(GravatarRating)
/// Gravatar Image Ratings for Objc compatibility.
public enum ObjcGravatarRating: Int {
    case g
    case pg
    case r
    case x

    fileprivate func map() -> Rating {
        switch self {
        case .g: .general
        case .pg: .parentalGuidance
        case .r: .restricted
        case .x: .x
        }
    }
}


/// UIImageView Helper Methods that allow us to download a Gravatar, given the User's Email
///
extension UIImageView {
    // TODO: Remove when Objc compatibility is not needed.
    @objc(downloadGravatarFor:gravatarRating:)
    /// Re-declaration for Objc compatibility
    public func objc_downloadGravatar(for email: String, gravatarRating: ObjcGravatarRating) {
        downloadGravatar(for: email, gravatarRating: gravatarRating.map(), placeholderImage: .gravatarPlaceholderImage)
    }

    /// Downloads and sets the User's Gravatar, given his email.
    /// - Parameters:
    ///   - email: The user's email
    ///   - gravatarRating: Expected image rating
    ///   - placeholderImage: Image to be used as Placeholder
    public func downloadGravatar(for email: String, gravatarRating: ImageRating = .general, placeholderImage: UIImage = .gravatarPlaceholderImage) {
        let gravatarURL = GravatarURL.url(for: email, preferredSize: .pixels(gravatarDefaultSize()), gravatarRating: gravatarRating)
        listenForGravatarChanges(forEmail: email)
        downloadGravatar(fullURL: gravatarURL, placeholder: placeholderImage, animate: false, failure: nil)
    }
    
    /// Downloads and sets the User's Gravatar, given his email.
    /// TODO: This is a convenience method. Please, remove once all of the code has been migrated over to Swift.
    ///
    /// - Parameters:
    ///     - email: the user's email
    ///     - rating: expected image rating
    ///
    @available(*, deprecated, message: "Use downloadGravatar(for email: String, gravatarRating: GravatarRating)")
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
    @available(*, deprecated, message: "Use downloadGravatar(for email: String, gravatarRating: ImageRating = .g, placeholderImage: UIImage = .gravatarPlaceholderImage)")
    @objc
    public func downloadGravatarWithEmail(_ email: String, rating: GravatarRatings = .default, placeholderImage: UIImage = .gravatarPlaceholderImage) {
        let gravatarURL = Gravatar.gravatarUrl(for: email, size: gravatarDefaultSize(), rating: rating)

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
    public func downloadGravatar(_ gravatar: GravatarURL?, placeholder: UIImage, animate: Bool, failure: ((Error?) -> ())? = nil) {
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
        let url = gravatar.url(with: .init(preferredSize: .pixels(size)))
        downloadGravatar(fullURL: url, placeholder: placeholder, animate: animate, failure: failure)
    }

    private func downloadGravatar(fullURL: URL?, placeholder: UIImage, animate: Bool, failure: ((Error?) -> ())? = nil) {
        self.gravatar.cancelImageDownload()
        let options: [ImageSettingOption] = [.imageCache(ImageCache.shared)]
        self.gravatar.setImage(with: fullURL,
                               placeholder: placeholder,
                               options: options) { [weak self] result in
            switch result {
            case .success:
                if animate {
                    self?.fadeInAnimation()
                }
            case .failure(let error):
                failure?(error)
            }
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
    @available(*, deprecated, message: "Use downloadGravatar(_ gravatar: GravatarURL?, placeholder: UIImage, animate: Bool, failure: ((Error?) -> ())? = nil).")
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
        guard let gravatarURL = Gravatar.gravatarUrl(for: email, size: gravatarDefaultSize(), rating: rating) else {
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
        static var gravatarWrapperKey = 0x1000
        static let emailKey = "email"
        static let imageKey = "image"
    }
}

public extension NSNotification.Name {
    static let GravatarImageUpdateNotification = NSNotification.Name(rawValue: "GravatarImageUpdateNotification")
}

import Foundation
import UIKit

#if SWIFT_PACKAGE
import WordPressUIObjC
#endif

public extension UIImageView {
    enum ImageDownloadError: Error {
        case noURLSpecifiedInRequest
        case urlMismatch
    }

    /// Downloads an image and updates the current UIImageView Instance.
    ///
    /// - Parameters:
    ///     -   url: The target Image's URL.
    ///     -   placeholderImage: Image to be displayed while the actual asset gets downloaded.
    ///     -   pointSize: *Maximum* allowed size. if the actual asset exceeds this size, we'll shrink it down.
    ///
    @objc func downloadResizedImage(from url: URL?, placeholderImage: UIImage? = nil, pointSize: CGSize) {
        downloadImage(from: url, placeholderImage: placeholderImage, success: { [weak self] image in
            guard image.size.height > pointSize.height || image.size.width > pointSize.width else {
                self?.image = image
                return
            }

            self?.image = image.resizedImage(with: .scaleAspectFit, bounds: pointSize, interpolationQuality: .high)
        })
    }

    /// Downloads an image and updates the current UIImageView Instance.
    ///
    /// - Parameters:
    ///     -   url: The URL of the target image
    ///     -   placeholderImage: Image to be displayed while the actual asset gets downloaded.
    ///     -   success: Closure to be executed on success.
    ///     -   failure: Closure to be executed upon failure.
    ///
    @objc func downloadImage(from url: URL?, placeholderImage: UIImage? = nil, success: ((UIImage) -> ())? = nil, failure: ((Error?) -> ())? = nil) {
        // Ideally speaking, this method should *not* receive an Optional URL. But we're doing so, for convenience.
        // If the actual URL was nil, at least we set the Placeholder Image. Capicci?
        guard let url = url else {
            cancelImageDownload()

            if let placeholderImage = placeholderImage {
                self.image = placeholderImage
            }

            return
        }

        let request = self.request(for: url)
        downloadImage(usingRequest: request, placeholderImage: placeholderImage, success: success, failure: failure)
    }

    /// Downloads an image and updates the current UIImageView Instance.
    ///
    /// - Parameters:
    ///     -   request: The request for the target image
    ///     -   placeholderImage: Image to be displayed while the actual asset gets downloaded.
    ///     -   success: Closure to be executed on success.
    ///     -   failure: Closure to be executed upon failure.
    ///
    @objc func downloadImage(usingRequest request: URLRequest, placeholderImage: UIImage? = nil, success: ((UIImage) -> ())? = nil, failure: ((Error?) -> ())? = nil) {
        let context = self.context
        context.cancel()

        let handleSuccess = { [weak self] (image: UIImage) in
            self?.image = image
            success?(image)
        }

        guard let url = request.url else {
            if let placeholderImage = placeholderImage {
                image = placeholderImage
            }

            failure?(ImageDownloadError.noURLSpecifiedInRequest)
            return
        }

        if let cachedImage = ImageCache.shared.getImage(forKey: url.absoluteString) {
            handleSuccess(cachedImage)
            return
        }

        // Using the placeholder only makes sense if we know we're going to download an image
        // that's not immediately available to us.
        if let placeholderImage = placeholderImage {
            self.image = placeholderImage
        }

        let taskId = context.getNextTaskId()
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            let image = data.flatMap(makeImage)
            DispatchQueue.main.async {
                guard context.taskId == taskId else { return }
                if let image {
                    ImageCache.shared.setImage(image, forKey: url.absoluteString)
                    handleSuccess(image)
                } else {
                    failure?(error)
                }
                context.task = nil
            }
        }
        context.task = task
        task.resume()
    }

    /// Overrides the cached UIImage, for a given URL. This is useful for whenever we've just updated a remote resource,
    /// and we need to prevent returning the (old) cached entry.
    @objc func overrideImageCache(for url: URL, with image: UIImage) {
        ImageCache.shared.setImage(image, forKey: url.absoluteString)

        // Remove all cached responses - removing an individual response does not work since iOS 7.
        // This feels hacky to do but what else can we do...
        //
        // Update: Years have gone by (iOS 11 era). Still broken. Still ashamed about this. Thank you, Apple.
        //
        URLSession.shared.configuration.urlCache?.removeAllCachedResponses()
    }

    /// Cancels the current download task and clear the downloadURL
    @objc func cancelImageDownload() {
        context.cancel()
    }

    /// Returns a URLRequest for an image, hosted at the specified URL.
    private func request(for url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpShouldHandleCookies = false
        request.addValue("image/*", forHTTPHeaderField: "Accept")
        return request
    }

    /// Stores image download context.
    private var context: ImageDownloadContext {
        if let context = objc_getAssociatedObject(self, &ImageDownloadContext.contextKey) as? ImageDownloadContext {
            return context
        }
        let context = ImageDownloadContext()
        objc_setAssociatedObject(self, &ImageDownloadContext.contextKey, context as AnyObject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return context
    }
}

// MARK: - Helpers

private final class ImageDownloadContext {
    var taskId = 0
    var task: URLSessionDataTask?

    static var contextKey: UInt8 = 0

    func getNextTaskId() -> Int {
        taskId += 1
        return taskId
    }

    func cancel() {
        taskId += 1
        task?.cancel()
        task = nil
    }
}

private func makeImage(with data: Data) -> UIImage? {
    guard !data.isEmpty, let image = UIImage(data: data) else {
        return nil
    }
    if #available(iOS 15.0, *) {
        // Decompress the image in the background
        return image.preparingForDisplay() ?? image
    } else {
        return image
    }
}

// MARK: - UIImageView+Networking (ImageCache)

public protocol ImageCaching {
    func setImage(_ image: UIImage, forKey key: String)
    func getImage(forKey key: String) -> UIImage?
}

public class ImageCache: ImageCaching {
    private let cache = NSCache<NSString, UIImage>()

    /// Changes the default cache used by the image dowloader.
    public static var shared: ImageCaching = ImageCache()

    public func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }

    public func getImage(forKey key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }
}

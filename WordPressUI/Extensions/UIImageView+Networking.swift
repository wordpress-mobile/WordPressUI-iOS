import Foundation


public extension UIImageView {

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
            if let placeholderImage = placeholderImage {
                image = placeholderImage
            }
            cancelImageDownload()
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
        // Ideally speaking, this method should *not* receive an Optional URL. But we're doing so, for convenience.
        // If the actual URL was nil, at least we set the Placeholder Image. Capicci?
        guard let url = request.url else {
            if let placeholderImage = placeholderImage {
                image = placeholderImage
            }
            cancelImageDownload()
            return
        }

        let internalOnSuccess = { [weak self] (image: UIImage) in
            self?.image = image
            success?(image)
        }

        let cachedImage = Downloader.cache.getImage(forURL: url)

        // If we are asking for the same URL let's just stay like we are
        guard url != downloadURL || taskFinishedWitherror() else {
            if let image = cachedImage {
                internalOnSuccess(image)
            }
            return
        }

        // Do this first, if there was any ongoing task for this imageview we need to cancel imediately or else we can apply the cache image and not cancel a previous download
        cancelImageDownload()
        downloadURL = url

        if let image = cachedImage {
            internalOnSuccess(image)
            return
        }

        if let placeholderImage = placeholderImage {
            image = placeholderImage
        }

        let task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] data, response, error in
            guard let data = data, let image = UIImage(data: data, scale: UIScreen.main.scale) else {
                failure?(error)
                return
            }

            DispatchQueue.main.async {
                Downloader.cache.insert(image, forKey: url)

                if response?.url == self?.downloadURL {
                    internalOnSuccess(image)
                }

                self?.downloadTask = nil
            }
        })

        downloadTask = task
        task.resume()
    }


    /// Overrides the cached UIImage, for a given URL. This is useful for whenever we've just updated a remote resource,
    /// and we need to prevent returning the (old) cached entry.
    ///
    @objc func overrideImageCache(for url: URL, with image: UIImage) {
        Downloader.cache.insert(image, forKey: url)

        // Remove all cached responses - removing an individual response does not work since iOS 7.
        // This feels hacky to do but what else can we do...
        //
        // Update: Years have gone by (iOS 11 era). Still broken. Still ashamed about this. Thank you, Apple.
        //
        URLSession.shared.configuration.urlCache?.removeAllCachedResponses()
    }
    
    @objc func getImageFromCache(for url: URL) -> UIImage? {
        return Downloader.cache.getImage(forURL: url)
    }

    /// Cancels the current download task and clear the downloadURL
    ///
    @objc func cancelImageDownload() {
        downloadURL = nil
        downloadTask?.cancel()
    }


    /// Returns true if the task finished with an error.
    ///
    private func taskFinishedWitherror() -> Bool {
        return downloadTask?.error != nil
    }

    /// Returns a URLRequest for an image, hosted at the specified URL.
    ///
    private func request(for url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpShouldHandleCookies = false
        request.addValue("image/*", forHTTPHeaderField: "Accept")

        return request
    }


    /// Stores the Image's remote URL, if any.
    ///
    internal var downloadURL: URL? {
        get {
            return objc_getAssociatedObject(self, &Downloader.urlKey) as? URL
        }
        set {
            objc_setAssociatedObject(self, &Downloader.urlKey, newValue as AnyObject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }


    /// Stores the current DataTask, in charge of downloading the remote Image.
    ///
    private var downloadTask: URLSessionDataTask? {
        get {
            return objc_getAssociatedObject(self, &Downloader.taskKey) as? URLSessionDataTask
        }
        set {
            objc_setAssociatedObject(self, &Downloader.taskKey, newValue as AnyObject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }


    /// Private helper structure
    ///
    private struct Downloader {

        /// Stores all of the previously downloaded images.
        ///
        static let cache = ImageCache()

        /// Key used to associate the current URL.
        ///
        static var urlKey = "urlKey"

        /// Key used to associate a Download task to the current instance.
        ///
        static var taskKey = "downloadTaskKey"
    }
}

public final class ImageCache {
    
    /// Wrap our public-facing Key values in order to make them NSCache compatible.
    private let storage = NSCache<WrappedKey, Entry>()
    
    /// Hold of the current date, in order to determine whether a given entry is still valid
    private let dateProvider: () -> Date
    
    /// Persistance
    private let persistance: Bool
    
    /// KeyTracker type, which will become the delegate of our underlying NSCache, in order to get notified whenever an entry was removed
    private let keyTracker = KeyTracker()

    /// Init method,
    /// Date provider: default current date
    /// Maximum entry count: 0 by default, so there is no count limit.
    /// If persistent is equal true, images are also stored on disk
    ///
    init(dateProvider: @escaping () -> Date = Date.init,
         maximumEntryCount: Int = 0,
         persistent: Bool = true) {
        self.dateProvider = dateProvider
        self.persistance = persistent
        storage.countLimit = maximumEntryCount
        storage.delegate = keyTracker
    }
    
    /// Insert a new value into cache
    func insert(_ image: UIImage, forKey key: URL) {
        let entry = Entry(key: key, value: image)
        storage.setObject(entry, forKey: WrappedKey(entry.key))
        try? saveImageToDisk(url: entry.key, image: entry.value)
        keyTracker.keys.insert(key)
    }

    /// Get a value from the cache
    func getImage(forURL url: URL) -> UIImage? {
        
        var entry = storage.object(forKey: WrappedKey(url))
        
        if entry == nil, let imageFromDisk = getImageFromDisk(url: url) {
            entry = Entry(key: url, value: imageFromDisk)
            if let entry = entry{
                storage.setObject(entry, forKey: WrappedKey(entry.key))
                keyTracker.keys.insert(url)
            }
        }

        return entry?.value
    }

    /// Remove a value from the cache
    func removeImage(forURL url: URL) {
        storage.removeObject(forKey: WrappedKey(url))
        removeImageFromDisk(url: url)
    }
    
   /// Stores data for the given key. The method returns instantly and the data
   /// is written asynchronously.
    private func saveImageToDisk(url: URL, image: UIImage) throws {
       guard persistance == true else {
           return
       }
        
       let fileManager: FileManager = .default
       let folderURLs = fileManager.urls(
           for: .cachesDirectory,
           in: .userDomainMask
       )
    
       let fileURL = folderURLs[0].appendingPathComponent(url.absoluteString.md5 + ".png")
        if let data = image.pngData(){
            try data.write(to: fileURL)
        }
    }
    
    private func getImageFromDisk(url: URL) -> UIImage?{
        guard persistance == true else {
            return nil
        }
        
        let directory = folderDirectory()
        let fileURL = directory.appendingPathComponent(url.absoluteString.md5 + ".png")
        return UIImage(contentsOfFile: fileURL.absoluteString)
    }
    
    private func removeImageFromDisk(url: URL){
        guard persistance == true else {
            return
        }
        
        let directory = folderDirectory()
        let fileURL = directory.appendingPathComponent(url.absoluteString.md5 + ".png")
        if fileManager().fileExists(atPath: fileURL.path){
            try? fileManager().removeItem(at: fileURL)
        }
    }
    
}

/// Helper private methods
///
private extension ImageCache {
    
    func folderDirectory() -> URL {
        let folderURLs = fileManager().urls(
            for: .cachesDirectory,
            in: .userDomainMask
        )
        
        return folderURLs[0]
    }
    
    func fileManager() -> FileManager {
        return .default
    }
}

extension ImageCache {
    final class Entry {
        let key: URL
        let value: UIImage

        init(key: URL, value: UIImage) {
            self.key = key
            self.value = value
        }
    }
}

private extension ImageCache {
    
    /// Wrap our public-facing Key values in order to make them NSCache compatible
    final class WrappedKey: NSObject {
        let key: URL

        init(_ key: URL) { self.key = key }

        override var hash: Int { return key.hashValue }

        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else {
                return false
            }

            return value.key == key
        }
    }
}

private extension ImageCache {
    final class KeyTracker: NSObject, NSCacheDelegate {
        var keys = Set<URL>()

        func cache(_ cache: NSCache<AnyObject, AnyObject>,
                   willEvictObject object: Any) {
            guard let entry = object as? Entry else {
                return
            }

            keys.remove(entry.key)
        }
    }
}

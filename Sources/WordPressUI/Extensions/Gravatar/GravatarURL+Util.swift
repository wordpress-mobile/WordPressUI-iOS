import Foundation
import Gravatar

extension GravatarURL {
    
    /// Creates a Gravatar URL. This is the new version of the deprecated method: `Gravatar.gravatarUrl(for:defaultImage:size:rating:)`
    /// - Parameters:
    ///   - email: The user's email
    ///   - preferredSize: Preferred size for the Gravatar image. See: `Gravatar.ImageSize`
    ///   - gravatarRating: Specifies a Gravatar image rating. See: Gravatar.GravatarRating
    ///   - defaultImageOption: Option to return a default image if the image requested does not exist. See.Gravatar.DefaultImageOption
    /// - Returns: Gravatar URL.
    public static func url(for email: String,
                           preferredSize: ImageSize? = nil,
                           gravatarRating: Rating? = nil,
                           defaultImageOption: DefaultImageOption? = .fileNotFound) -> URL? {
        return GravatarURL.gravatarUrl(with: email,
                                       // TODO: Passing GravatarDefaults.imageSize to keep the previous default.
                                       // But ideally this should be passed explicitly.
                                       options: .init(preferredSize: preferredSize ?? .pixels(GravatarDefaults.imageSize),
                                                      rating: gravatarRating,
                                                      defaultImageOption: defaultImageOption))
    }
}

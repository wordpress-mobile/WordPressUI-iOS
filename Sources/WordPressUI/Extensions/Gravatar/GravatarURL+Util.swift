import Foundation
import Gravatar

extension AvatarURL {
    /// Creates a Gravatar URL. This is the new version of the deprecated method: `Gravatar.gravatarUrl(for:defaultImage:size:rating:)`
    /// - Parameters:
    ///   - email: The user's email
    ///   - preferredSize: Preferred size for the Gravatar image. See: `Gravatar.ImageSize`
    ///   - gravatarRating: Specifies a Gravatar image rating. See: Gravatar.GravatarRating
    ///   - defaultAvatarOption: Option to return a default image if the image requested does not exist. See: Gravatar.DefaultAvatarOption
    /// - Returns: Gravatar URL.
    public static func url(for email: String,
                           preferredSize: ImageSize? = nil,
                           gravatarRating: Rating? = nil,
                           defaultAvatarOption: DefaultAvatarOption? = .status404) -> URL? {
        AvatarURL(
            with: .email(email),
            // TODO: Passing GravatarDefaults.imageSize to keep the previous default.
            // But ideally this should be passed explicitly.
            options: .init(
                preferredSize: preferredSize ?? .pixels(GravatarDefaults.imageSize),
                rating: gravatarRating,
                defaultAvatarOption: defaultAvatarOption
            )
        )?.url
    }
}

//
//  UIImage+Gravatar.swift
//
//
//  Created by Andrew Montgomery on 1/25/24.
//

import Foundation
import UIKit
import WordPressUI

extension UIImage {
    /// Returns the Default Gravatar Placeholder Image.
    ///
    @objc
    public static var gravatarPlaceholderImage: UIImage {
        return UIImage(named: "gravatar", in: Bundle.wordPressUIBundle, compatibleWith: nil)!
    }
}

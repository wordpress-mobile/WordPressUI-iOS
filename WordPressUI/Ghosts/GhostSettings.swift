import Foundation
import UIKit


// MARK: - GhostSettings: Handles the active Ghost Parameters.
//
enum GhostSettings {

    /// Default Animation Duration.
    ///
    static var beatDuration = TimeInterval(0.75)

    /// Default Beat StartColor: Applied at the initial state of the Beat animation.
    ///
    static var beatStartColor = UIColor(red: 236.0/255.0, green: 240.0/255.0, blue: 241.0/255.0, alpha: 1.0)

    /// Default Beat EndColor: Applied at the final state of the Beat animation.
    ///
    static var beatEndColor = UIColor(red: 245.0/255.0, green: 250.0/255.0, blue: 250.0/255.0, alpha: 1.0)
}

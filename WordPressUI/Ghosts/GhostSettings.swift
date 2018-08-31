import Foundation
import UIKit


// MARK: - GhostSettings: Handles the active Ghost Parameters.
//
public struct GhostSettings {

    /// Default Animation Duration.
    ///
    let beatDuration: TimeInterval

    /// Beat Initial Color: Applied at the beginning of the Beat Animation.
    ///
    let beatStartColor: UIColor

    /// Beat Final Color: Applied at the end of the Beat Animation.
    ///
    let beatEndColor: UIColor

    /// GhostCell(s) Reuse Identifier.
    ///
    let reuseIdentifier: String

    /// Indicates how many Sections / Rows per Section should be rendered.
    ///
    let rowsPerSection: [Int]

    /// Indicates if an Emtpy SectionHeader should be rendered (for placeholder purposes).
    ///
    let displaysSectionHeader: Bool


    /// Designated Initializer
    ///
    public init(beatDuration: TimeInterval = Defaults.beatDuration,
                beatStartColor: UIColor = Defaults.beatStartColor,
                beatEndColor: UIColor = Defaults.beatEndColor,
                displaysSectionHeader: Bool = Defaults.displaysSectionHeader,
                reuseIdentifier: String,
                rowsPerSection: [Int])
    {
        self.beatDuration = beatDuration
        self.beatStartColor = beatStartColor
        self.beatEndColor = beatEndColor
        self.displaysSectionHeader = displaysSectionHeader
        self.reuseIdentifier = reuseIdentifier
        self.rowsPerSection = rowsPerSection
    }
}


// MARK: - Nested Types
//
extension GhostSettings {

    public struct Defaults {
        public static let beatDuration = TimeInterval(0.75)
        public static let beatStartColor = UIColor(red: 236.0/255.0, green: 240.0/255.0, blue: 241.0/255.0, alpha: 1.0)
        public static let beatEndColor = UIColor(red: 245.0/255.0, green: 250.0/255.0, blue: 250.0/255.0, alpha: 1.0)
        public static let displaysSectionHeader = true
    }
}

import XCTest

@testable import WordPressUI

class UIViewAutoLayoutHelperTests: XCTestCase {
    private lazy var view: UIView = {
        return UIView(frame: .zero)
    }()

    private lazy var subview: UIView = {
        return UIView(frame: .zero)
    }()

    // MARK: tests for `pinSubviewToAllEdges`

    func testPinSubviewToAllEdgesWithZeroInsets() {
        view.addSubview(subview)
        view.pinSubviewToAllEdges(subview)

        let topConstraint = getConstraint(from: view, filter: { $0.firstAnchor == view.topAnchor })
        XCTAssertEqual(topConstraint.constant, 0)
        XCTAssertEqual(topConstraint.secondAnchor, subview.topAnchor)

        let leadingConstraint = getConstraint(from: view, filter: { $0.firstAnchor == view.leadingAnchor })
        XCTAssertEqual(leadingConstraint.constant, 0)
        XCTAssertEqual(leadingConstraint.secondAnchor, subview.leadingAnchor)

        let trailingConstraint = getConstraint(from: view, filter: { $0.firstAnchor == view.trailingAnchor })
        XCTAssertEqual(trailingConstraint.constant, 0)
        XCTAssertEqual(trailingConstraint.secondAnchor, subview.trailingAnchor)

        let bottomConstraint = getConstraint(from: view, filter: { $0.firstAnchor == view.bottomAnchor })
        XCTAssertEqual(bottomConstraint.constant, 0)
        XCTAssertEqual(bottomConstraint.secondAnchor, subview.bottomAnchor)
    }

    func testPinSubviewToAllEdgesWithNonZeroInsets() {
        view.addSubview(subview)
        let insets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        view.pinSubviewToAllEdges(subview, insets: insets)

        // Self.top = subview.top - insets.top
        let topConstraint = getConstraint(from: view, filter: { $0.firstAnchor == view.topAnchor })
        XCTAssertEqual(topConstraint.constant, -insets.top)
        XCTAssertEqual(topConstraint.secondAnchor, subview.topAnchor)

        // Self.leading = subview.leading - insets.left
        let leadingConstraint = getConstraint(from: view, filter: { $0.firstAnchor == view.leadingAnchor })
        XCTAssertEqual(leadingConstraint.constant, -insets.left)
        XCTAssertEqual(leadingConstraint.secondAnchor, subview.leadingAnchor)

        // Self.trailing = subview.trailing + insets.right
        let trailingConstraint = getConstraint(from: view, filter: { $0.firstAnchor == view.trailingAnchor })
        XCTAssertEqual(trailingConstraint.constant, insets.right)
        XCTAssertEqual(trailingConstraint.secondAnchor, subview.trailingAnchor)

        // Self.bottom = subview.bottom + insets.bottom
        let bottomConstraint = getConstraint(from: view, filter: { $0.firstAnchor == view.bottomAnchor })
        XCTAssertEqual(bottomConstraint.constant, insets.bottom)
        XCTAssertEqual(bottomConstraint.secondAnchor, subview.bottomAnchor)
    }

    private func getConstraint(from view: UIView, filter: (NSLayoutConstraint) -> Bool) -> NSLayoutConstraint {
        let constraints = view.constraints.filter(filter)
        guard let constraint = constraints.first, constraints.count == 1 else {
            XCTFail("View top constraint should have been created")
            fatalError()
        }
        return constraint
    }
}

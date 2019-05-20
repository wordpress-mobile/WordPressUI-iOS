import XCTest

@testable import WordPressUI

class UITableViewGhostTests: XCTestCase {
    func testCallWillStartGhostAnimationBeforeAnimating() {
        let tableView = UITableView()
        tableView.register(GhostMockCell.self, forCellReuseIdentifier: "ghost")
        tableView.displayGhostContent(options: GhostOptions(reuseIdentifier: "ghost", rowsPerSection: [1]), style: .default)

        tableView.dataSource?.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0))
        
        XCTAssertTrue(GhostMockCell.willStartGhostAnimationCalled)
    }

    func testCellDoesntHaveToConformToGhostCellDelegate() {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.displayGhostContent(options: GhostOptions(reuseIdentifier: "cell", rowsPerSection: [1]), style: .default)

        let cell = tableView.dataSource?.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0))

        XCTAssertNotNil(cell)
    }
}

class GhostMockCell: UITableViewCell, GhostableView {
    static var willStartGhostAnimationCalled = false

    func ghostAnimationWillStart() {
        GhostMockCell.willStartGhostAnimationCalled = true
    }
}

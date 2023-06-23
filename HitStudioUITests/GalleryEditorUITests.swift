//
//  GalleryEditorUITests.swift
//  HitStudio
//
//  Created by freegatik on 23.06.2023.
//

import XCTest

final class GalleryEditorUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-UITESTSeedGallery"]
        app.launch()
    }

    func testGalleryShowsPhotosHeader() {
        app.buttons["Image editor"].tap()
        XCTAssertTrue(app.staticTexts["Photos"].waitForExistence(timeout: 8))
    }

    func testNavigateToEditorAndSeeSave() {
        app.buttons["Image editor"].tap()
        let start = UITestQuery.element(app: app, id: "gallery.nav.startEditing")
        XCTAssertTrue(start.waitForExistence(timeout: 10))
        start.tap()
        XCTAssertTrue(app.buttons["Save"].firstMatch.waitForExistence(timeout: 12))
    }

    func testEditorRotateToolAndBackToGallery() {
        app.buttons["Image editor"].tap()
        let start = UITestQuery.element(app: app, id: "gallery.nav.startEditing")
        XCTAssertTrue(start.waitForExistence(timeout: 10))
        start.tap()
        let rotate = UITestQuery.element(app: app, id: "editor.tool.rotate")
        XCTAssertTrue(rotate.waitForExistence(timeout: 8))
        rotate.tap()
        XCTAssertTrue(app.buttons["editor.nav.back"].waitForExistence(timeout: 4))
        app.buttons["editor.nav.back"].tap()
        XCTAssertTrue(app.staticTexts["Photos"].waitForExistence(timeout: 8))
    }
}

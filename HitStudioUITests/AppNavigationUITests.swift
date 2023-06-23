//
//  AppNavigationUITests.swift
//  HitStudio
//
//  Created by freegatik on 12.06.2023.
//

import XCTest

final class AppNavigationUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testWelcomeShowsTitle() {
        XCTAssertTrue(app.staticTexts["Hit Studio"].waitForExistence(timeout: 8))
    }

    func testNavigateToGalleryAndBack() {
        XCTAssertTrue(app.buttons["Image editor"].waitForExistence(timeout: 8))
        app.buttons["Image editor"].tap()
        XCTAssertTrue(app.staticTexts["Photos"].waitForExistence(timeout: 8))
        let back = app.buttons["Back"].firstMatch
        XCTAssertTrue(back.waitForExistence(timeout: 4))
        back.tap()
        XCTAssertTrue(app.staticTexts["Hit Studio"].waitForExistence(timeout: 8))
    }

    func testNavigateToVectorAndBack() {
        XCTAssertTrue(app.buttons["Vector Editor"].waitForExistence(timeout: 8))
        app.buttons["Vector Editor"].tap()
        let canvas = UITestQuery.element(app: app, id: "vector.drawingCanvas")
        XCTAssertTrue(canvas.waitForExistence(timeout: 8))
        XCTAssertTrue(app.buttons["vector.nav.back"].waitForExistence(timeout: 4))
        app.buttons["vector.nav.back"].tap()
        XCTAssertTrue(app.staticTexts["Hit Studio"].waitForExistence(timeout: 8))
    }

    func testNavigateToCubeScene() {
        XCTAssertTrue(app.buttons["3D Cube"].waitForExistence(timeout: 8))
        app.buttons["3D Cube"].tap()
        let scn = UITestQuery.element(app: app, id: "cube.scnView")
        XCTAssertTrue(scn.waitForExistence(timeout: 10))
    }

    func testVectorDeleteToggleExists() {
        app.buttons["Vector Editor"].tap()
        XCTAssertTrue(app.buttons["vector.toggleDelete"].waitForExistence(timeout: 6))
    }
}

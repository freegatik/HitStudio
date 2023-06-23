//
//  UITestBase.swift
//  HitStudio
//
//  Created by freegatik on 05.06.2023.
//

import XCTest

enum UITestQuery {
    static func element(app: XCUIApplication, id: String) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: id).element
    }
}

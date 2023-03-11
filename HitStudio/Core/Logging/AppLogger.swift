//
//  AppLogger.swift
//  HitStudio
//
//  Created by freegatik on 09.03.2023.
//

import Foundation
import os

enum AppLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "HitStudio"
    private static let general = Logger(subsystem: subsystem, category: "general")
    private static let images = Logger(subsystem: subsystem, category: "imageProcessing")

    static func debug(_ message: String) {
        general.debug("\(message, privacy: .public)")
    }

    static func info(_ message: String) {
        general.info("\(message, privacy: .public)")
    }

    static func error(_ message: String) {
        general.error("\(message, privacy: .public)")
    }

    static func imagePipeline(_ message: String) {
        images.notice("\(message, privacy: .public)")
    }
}

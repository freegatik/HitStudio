//
//  AnalyticsTracking.swift
//  HitStudio
//
//  Created by freegatik on 11.03.2023.
//

import Foundation

protocol AnalyticsTracking: AnyObject {
    func trackScreen(_ name: String)
    func trackEvent(_ name: String, parameters: [String: String]?)
}

final class NoOpAnalytics: AnalyticsTracking {
    func trackScreen(_ name: String) {}

    func trackEvent(_ name: String, parameters: [String: String]?) {}
}

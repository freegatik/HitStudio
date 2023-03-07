//
//  AppDependencies.swift
//  HitStudio
//
//  Created by freegatik on 07.03.2023.
//

import SwiftUI

final class AppDependencies: ObservableObject {
    let editorViewModel: EditImageViewModel
    let analytics: AnalyticsTracking

    init(
        editorViewModel: EditImageViewModel = EditImageViewModel(),
        analytics: AnalyticsTracking = NoOpAnalytics()
    ) {
        self.editorViewModel = editorViewModel
        self.analytics = analytics
    }
}

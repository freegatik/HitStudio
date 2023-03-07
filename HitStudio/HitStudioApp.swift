//
//  HitStudioApp.swift
//  HitStudio
//
//  Created by freegatik on 05.03.2023.
//

import SwiftUI

@main
struct HitStudioApp: App {
    @StateObject private var dependencies = AppDependencies()

    var body: some Scene {
        WindowGroup {
            WelcomeView()
                .environmentObject(dependencies)
        }
    }
}

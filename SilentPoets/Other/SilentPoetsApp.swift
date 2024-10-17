//
//  SilentPoetsApp.swift
//  SilentPoets
//
//  Created by Trịnh Kiết Tường on 14/10/24.
//

import SwiftUI
import SwiftData

@main
struct SilentPoetsApp: App {

    var body: some Scene {
        WindowGroup {
            MainView()
                .modelContainer(for: [FavorBook.self, TrackingBook.self])
        }
    }
}

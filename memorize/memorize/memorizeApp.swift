//
//  memorizeApp.swift
//  memorize
//
//  Created by Hang Zhang on 9/18/21.
//

import SwiftUI

@main
struct memorizeApp: App {
    @StateObject var themeStore = ThemeStore()

    var body: some Scene {
        WindowGroup {
            ThemeChooser().environmentObject(themeStore)
        }
    }
}

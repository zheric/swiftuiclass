//
//  memorizeApp.swift
//  memorize
//
//  Created by Hang Zhang on 9/18/21.
//

import SwiftUI

@main
struct memorizeApp: App {
    var body: some Scene {
        let game = GameViewModel()
        WindowGroup {
            ContentView(game: game)
        }
    }
}

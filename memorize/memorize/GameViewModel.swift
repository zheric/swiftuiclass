//
//  GameViewModel.swift
//  memorize
//
//  Created by Hang Zhang on 9/20/21.
//

import SwiftUI

class GameViewModel : ObservableObject{
    
    @EnvironmentObject var store : ThemeStore
    
    var currentTheme : Theme {
        didSet {
            if currentTheme != oldValue {
                self.startNewGame()
            }
        }
    }
    
    @Published var gameModel : GameModel
    
    var cardColor : Color {
        switch currentTheme.color {
        case "red": return .red
        case "blue": return .blue
        case "yellow": return .yellow
        case "pink": return .pink
        case "green": return .green
        case "orange": return .orange
        default: return .red
        }
    }
    
    init(with theme:Theme) {
        gameModel = GameModel(with:theme)
        currentTheme = theme
    }
    
    var cards : [GameModel.Card] {
        gameModel.cards
    }
    
    var name : String {
        gameModel.themeName
    }
    
    var score : Int {
        gameModel.score
    }
    // MARK: -- intents
    func startNewGame() {
        gameModel = GameModel(with: currentTheme)
    }
    
    func select(_ card: GameModel.Card) {
        gameModel.select(card)
    }
}

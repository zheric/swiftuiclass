//
//  GameViewModel.swift
//  memorize
//
//  Created by Hang Zhang on 9/20/21.
//

import SwiftUI

class GameViewModel : ObservableObject{
    
    static let themes = [
        Theme(name: "Vehicles", emojis: ["🚗", "🚌", "🚎", "🏎", "🚑", "🚜", "🛻", "🚒", "🚅", "✈️"], color: "red", numPairsOfEmojis: 10),
        Theme(name: "House", emojis: ["🏘", "🏕", "⛺️", "🛖","🏠", "🏚", "🏭", "🏢", "🏬", "🏣", "🏤", "🏥", "🏦", "🏨", "🏪", "🏫", "🏩", "💒", "🏛", "⛪️", "🕌", "⛩"], color: "blue", numPairsOfEmojis:5),
        Theme(name: "People", emojis: ["👶", "👧", "🧑‍🦰", "🧑‍🦳", "👮‍♂️", "🧓🏽", "🧔🏿‍♀️", "👱🏻‍♀️", "🧑‍🎨", "👨‍🚀", "🥷", "🧝", "🎅🏻", "🧙‍♀️", "🦹", "🧛"], color: "yellow", numPairsOfEmojis: 6),
        Theme(name: "Flower", emojis: ["🌺", "🌸", "🌼", "🌻", "🌷", "🌹"], color:"green", numPairsOfEmojis: 5),
        Theme(name: "Animal", emojis: ["🐝","🐛","🦋","🐌","🐥","🪰","🐠","🐳"], color:"pink", numPairsOfEmojis: 6),
        Theme(name: "Food", emojis: ["🍏","🍉","🍇","🍓","🍍","🍒","🍑","🍊"], color:"orange", numPairsOfEmojis: 8)
    ]
    
    static func createMemoryGame() -> (GameModel, Color) {
        if let theme = themes.randomElement() {
            return (GameModel(withTheme: theme), colorFromTheme(theme))
        }
        return (GameModel(withTheme: Theme(name:"nil")), .red)
    }
    
    static func colorFromTheme(_ theme:Theme) -> Color {
        switch theme.color {
        case "yellow" : return .yellow
        case "blue" : return .blue
        case "green" : return .green
        case "pink": return .pink
        case "orange": return .orange
        case "purple" : return .purple
        default: return .red
        }
    }
    
    @Published var gameModel : GameModel
    var cardColor : Color
    
    init() {
        (gameModel, cardColor) = GameViewModel.createMemoryGame()
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
        (gameModel, cardColor) = GameViewModel.createMemoryGame()
    }
    
    func select(_ card: GameModel.Card) {
        gameModel.select(card)
    }
    
    struct Theme {
        var name : String
        var emojis : [String] = []
        var color : String = "red"
        var numPairsOfEmojis : Int = 0
    }

}

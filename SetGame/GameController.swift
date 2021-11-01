//
//  GameController.swift
//  SetGame
//
//  Created by Hang Zhang on 9/29/21.
//

import Foundation


class GameController : ObservableObject {
    
    @Published private var gameModel : SetGame
    
    init() {
        gameModel = SetGame()
    }
    
    var dealtCards : [SetGame.Card] {
        gameModel.dealtCards
    }
    
    var undealtCards : [SetGame.Card] {
        gameModel.unDealtCards
    }
    
    var discardPile : [SetGame.Card] {
        gameModel.discardPile
    }
    
    func select(_ card: SetGame.Card) {
        gameModel.select(card)
    }
    
    func dealCards() {
        gameModel.dealCards()
    }
    
    func restart() {
        gameModel = SetGame()
    }
}

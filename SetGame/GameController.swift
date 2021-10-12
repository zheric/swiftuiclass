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
    
    var cards : [SetGame.Card] {
        gameModel.dealtCards
    }
    
    func select(_ card: SetGame.Card) {
        gameModel.select(card)
    }
    
    func dealCards() {
        gameModel.dealCards()
    }
}

//
//  GameModel.swift
//  memorize
//
//  Created by Hang Zhang on 9/20/21.
//

import Foundation

struct GameModel {
    private(set) var cards : [Card] = []
    private(set) var themeName : String
    private(set) var score = 0
    private var matchCount = 0
    
    private var indexOfLastOpenedCard : Int?
    {
        get{ cards.indices.filter{ cards[$0].faceUp }.oneAndOnly }
        set{ cards.indices.forEach{ cards[$0].faceUp = ($0 == newValue)}}
    }
    
    private var gameFinised : Bool {
        matchCount == cards.count
    }
    
    init() {
        themeName = ""
    }
    
    init(with theme:Theme) {
        let shuffledEmojis = theme.emojis.shuffled()
        for index in 0..<min(theme.numPairsOfEmojis, theme.emojis.count) {
            self.cards.append(Card(content:String(shuffledEmojis[index]), id:index*2))
            self.cards.append(Card(content:String(shuffledEmojis[index]), id:index*2+1))
        }
        self.cards.shuffle()
        themeName = theme.name
    }
    
    mutating func select(_ card:Card) {
        if gameFinised {
            cards.indices.forEach{cards[$0].faceUp = false}
            return
        }
        if let chosenIdx = cards.firstIndex(where:{ $0.id == card.id })
            , !cards[chosenIdx].faceUp
            , !cards[chosenIdx].matched
        {
            if let lastCardIndex = indexOfLastOpenedCard {
                if cards[lastCardIndex].content == cards[chosenIdx].content {
                    cards[lastCardIndex].matched = true
                    cards[chosenIdx].matched = true
                    score += 2
                    matchCount += 2
                } else {
                    score -= 1
                }
                cards[chosenIdx].faceUp.toggle()
            } else {
                indexOfLastOpenedCard = chosenIdx
            }
        }
    }
    
    struct Card : Identifiable {
        var content : String
        var id: Int
        var faceUp = false
        var matched = false
    }
}

extension Array {
    var oneAndOnly : Element? {
        if self.count == 1 {
            return self.first
        }
        return nil
    }
}

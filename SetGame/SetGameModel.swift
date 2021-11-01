//
//  SetGameModel.swift
//  SetGame
//
//  Created by Hang Zhang on 9/28/21.
//

import Foundation

struct SetGame {
    enum ShapeType   : CaseIterable { case oval, diamond, squiggle }
    enum ShadingType : CaseIterable { case open, solid, striped    }
    enum ColorType   : CaseIterable { case green, purple, red      }
    
    struct Card : Identifiable {
        var shape : ShapeType
        var shade : ShadingType
        var color : ColorType
        var count : Int
        var id: Int
        var matched = false
        var selected = false
        var dealt = false
        var discarded = false
    }
    
    static func generateCards() -> [Card] {
        var cards = Array<Card>()
        for shape in ShapeType.allCases {
            for shading in ShadingType.allCases {
                for color in ColorType.allCases {
                    for n in 1...3 {
                        cards.append(Card(shape: shape,
                                          shade: shading,
                                          color: color,
                                          count: n,
                                          id: cards.count))
                    }
                }
            }
        }
        return cards.shuffled()
    }
    
    private(set) var cards : [Card]
    
    var selectedCardsCount : Int {
        dealtCards.filter{ $0.selected }.count
    }
    
    var discardPile : [Card] {
        cards.filter { $0.discarded }
    }
    
    var dealtCards : [Card] {
        cards.filter{ $0.dealt && !$0.discarded }
    }
    
    var unDealtCards : [Card] {
        cards.filter{ !$0.dealt && !$0.matched }
    }
    
    init() {
        cards = Self.generateCards()
    }
        
    mutating func resetActiveCards() -> Void {
        for idx in cards.indices {
            cards[idx].selected = false
        }
    }
    
    mutating func select(_ card: Card) {
        discardMatchedCard()
        if let idx = cards.firstIndex(where: { $0.id == card.id }) {
            if selectedCardsCount >= 3 {
                resetActiveCards()
            }
    
            cards[idx].selected.toggle()
            
            if setFormed() {
                markSetMatched()
            }
        }
    }
    
    mutating func discardMatchedCard() {
        for idx in cards.indices.filter({ cards[$0].matched }) {
            cards[idx].discarded = true
        }
    }
    
    mutating func dealCards() {
        discardMatchedCard()
        let numCardsDealt = dealtCards.count + discardPile.count
        for idx in numCardsDealt..<min(cards.count, numCardsDealt+3) {
            cards[idx].dealt = true
        }
        print("dealt \(dealtCards.count) cards")
    }
    
    private func cardsOfDistinctNumber(_ cards:[Card]) -> Bool {
        var ZERO = 0
        for card in cards { ZERO ^= card.count }
        return ZERO == 0
    }
    
    private func cardsOfSameNumber(_ cards:[Card]) -> Bool {
        return cards.allSatisfy { $0.count == cards.first!.count }
    }
    
    private func cardsOfSameShape(_ cards:[Card]) -> Bool {
        return cards.allSatisfy { $0.shape == cards.first!.shape }
    }
    
    private func cardsOfDistinctShape(_ cards:[Card]) -> Bool {
        let s : Set = Set(cards.map{$0.shape})
        return s.count == cards.count
    }
    
    private func cardsOfSameColor(_ cards:[Card]) -> Bool {
        return cards.allSatisfy { $0.color == cards.first!.color }
    }
    
    private func cardsOfDistinctColor(_ cards:[Card]) -> Bool {
        let s : Set = Set(cards.map{$0.color})
        return s.count == cards.count
    }
    
    private func cardsOfSameShading(_ cards:[Card]) -> Bool {
        return cards.allSatisfy { $0.shade == cards.first!.shade }
    }
    
    private func cardsOfDistinctShading(_ cards:[Card]) -> Bool {
        let s : Set = Set(cards.map{$0.shade})
        return s.count == cards.count
    }
    
    private func setFormed() -> Bool {
        if selectedCardsCount < 3 {
            return false
        }
        let selectedCards = cards.filter{$0.selected}
        return cardsFormASet(selectedCards)
    }
    private func cardsFormASet(_ cards:[Card]) -> Bool {
        let numbersRule = cardsOfSameNumber(cards) || cardsOfDistinctNumber(cards)
        let colorRule = cardsOfSameColor(cards) || cardsOfDistinctColor(cards)
        let shadeRule = cardsOfSameShading(cards) || cardsOfDistinctShading(cards)
        let shapeRule = cardsOfSameShape(cards) || cardsOfDistinctShape(cards)
        print("numbersRule: \(numbersRule)")
        print("colorRule: \(colorRule)")
        print("shadeRule: \(shadeRule)")
        print("shapeRule: \(shapeRule)")
        return numbersRule && colorRule && shadeRule && shapeRule;
    }
    
    private mutating func markSetMatched() {
        let selectedCardsIndices = cards.indices.filter{cards[$0].selected }
        guard selectedCardsIndices.count == 3 else {
            return
        }
        for i in selectedCardsIndices {
            cards[i].matched = true
        }
    }
}

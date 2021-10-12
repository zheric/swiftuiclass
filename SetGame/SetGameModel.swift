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
        var number : Int
        var id: Int
        var selected = false
        var matched = false
    }
    
    private(set) var cards : [Card]
    private(set) var dealtCards : [Card]
    
    init() {
        cards = Self.generateCards()
        dealtCards = []
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
                                          number: n,
                                          id: cards.count))
                    }
                }
            }
        }
        return cards.shuffled()
    }
    
    private var selectedCardsCount : Int = 0
    
    mutating func select(_ card: Card) {
        // removed any matched cards
        dealtCards = dealtCards.filter { $0.matched == false }

        if let idx = dealtCards.firstIndex(where: { $0.id == card.id }) {
            if selectedCardsCount >= 3 {
                // unselect cards
                for idx in dealtCards.indices {
                    dealtCards[idx].selected = false;
                }
                selectedCardsCount = 0;

            }
            
            dealtCards[idx].selected.toggle()
            selectedCardsCount += dealtCards[idx].selected ? 1 : -1;
            
            if selectedCardsCount >= 3 {
                if cardsFormASet(dealtCards.filter{$0.selected}) {
                    let selectedCardsIndices = dealtCards.indices.filter { dealtCards[$0].selected == true }
                    for idx in selectedCardsIndices {
                        dealtCards[idx].matched = true
                    }
                }
            }
        }
    }
    
    mutating func dealCards() {
        if cards.count < 3 { return }
        let cnt = cards.count
        dealtCards.append(contentsOf: cards[cnt-3..<cnt])
        cards.removeSubrange(cnt-3..<cnt)
    }
    
    private func cardsOfDistinctNumber(_ cards:[Card]) -> Bool {
        var ZERO = 0
        for card in cards { ZERO ^= card.number }
        return ZERO == 0
    }
    
    private func cardsOfSameNumber(_ cards:[Card]) -> Bool {
        return cards.allSatisfy { $0.number == cards.first!.number }
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
    
    
}

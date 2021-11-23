//
//  ThemeStore.swift
//  memorize
//
//  Created by Eric Zhang on 11/22/21.
//

import Foundation

struct Theme : Identifiable, Hashable {
    var name : String
    var emojis : String
    var color : String
    var numPairsOfEmojis : Int = 0
    var id : Int
    
    
    static func ==(lhs: Theme, rhs: Theme) -> Bool {
        (lhs.name, lhs.emojis, lhs.color, lhs.numPairsOfEmojis, lhs.id)
        == (rhs.name, rhs.emojis, rhs.color, rhs.numPairsOfEmojis, rhs.id)
    }
    
    static func !=(lhs: Theme, rhs: Theme) -> Bool {
        !(lhs == rhs)
    }
}

class ThemeStore : ObservableObject {
    @Published var themes : [Theme]
    
    var themeID : Int = 0
    init() {
        themes = [
            Theme(name: "Vehicles", emojis: "🚗🚌🚎🏎🚑🚜🛻🚒🚅✈️", color: "red", numPairsOfEmojis: 10, id: 0),
            Theme(name: "House", emojis: "🏘🏕⛺️🛖🏠🏚🏭🏢🏬🏣🏤🏥🏦🏨🏪🏫🏩💒🏛⛪️🕌⛩", color: "blue", numPairsOfEmojis:5, id: 1),
            Theme(name: "People", emojis: "👶👧🧑‍🦰🧑‍🦳👮‍♂️🧓🏽🧔🏿‍♀️👱🏻‍♀️🧑‍🎨👨‍🚀🥷🧝🎅🏻🧙‍♀️🦹🧛", color: "yellow", numPairsOfEmojis: 6, id: 2),
            Theme(name: "Flower", emojis: "🌺🌸🌼🌻🌷🌹", color: "green", numPairsOfEmojis: 5, id:3),
            Theme(name: "Animal", emojis: "🐝🐛🦋🐌🐥🪰🐠🐳", color: "pink", numPairsOfEmojis: 6, id:4),
            Theme(name: "Food", emojis: "🍏🍉🍇🍓🍍🍒🍑🍊", color:"orange", numPairsOfEmojis: 8, id:5)
        ]
        themeID = themes.count
    }
    
    func theme(at index:Int) -> Theme {
        let safeIdx = min(max(0, index), themes.count - 1)
        return themes[safeIdx]
    }
    
    func addTheme(name: String, emojis: String, color: String) -> Theme {
        themes.append(Theme(name: name, emojis: emojis, color: color, numPairsOfEmojis: emojis.count, id: themeID))
        themeID = themeID + 1
        return themes.last!
    }
}

extension Collection where Element: Identifiable {
    func index(matching element: Element) -> Self.Index? {
        firstIndex(where: { $0.id == element.id })
    }
}

extension RangeReplaceableCollection where Element: Identifiable {
    mutating func remove(_ element: Element) {
        if let index = index(matching: element) {
            remove(at: index)
        }
    }

    subscript(_ element: Element) -> Element {
        get {
            if let index = index(matching: element) {
                return self[index]
            } else {
                return element
            }
        }
        set {
            if let index = index(matching: element) {
                replaceSubrange(index...index, with: [newValue])
            }
        }
    }
}

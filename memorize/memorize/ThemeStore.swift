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
    
    static private var themeID : Int = 0
    
    init(name:String, emojis:String, color:String) {
        self.name = name
        self.emojis = emojis
        self.color = color
        self.id = Theme.themeID
        Theme.themeID = Theme.themeID + 1
    }
    
    init(name:String, emojis:String, color:String, numPairsOfEmojis:Int) {
        self.name = name
        self.emojis = emojis
        self.color = color
        self.id = Theme.themeID
        self.numPairsOfEmojis = numPairsOfEmojis
        Theme.themeID = Theme.themeID + 1
    }
    
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
    
    init() {
        themes = [
            Theme(name: "Vehicles", emojis: "đđđđđđđ»đđâïž", color: "red", numPairsOfEmojis: 10),
            Theme(name: "House", emojis: "đđâșïžđđ đđ­đąđŹđŁđ€đ„đŠđšđȘđ«đ©đđâȘïžđâ©", color: "blue", numPairsOfEmojis:5),
            Theme(name: "People", emojis: "đ¶đ§đ§âđŠ°đ§âđŠłđźââïžđ§đœđ§đżââïžđ±đ»ââïžđ§âđšđšâđđ„·đ§đđ»đ§ââïžđŠčđ§", color: "yellow", numPairsOfEmojis: 6),
            Theme(name: "Flower", emojis: "đșđžđŒđ»đ·đč", color: "green", numPairsOfEmojis: 5),
            Theme(name: "Animal", emojis: "đđđŠđđ„đȘ°đ đł", color: "pink", numPairsOfEmojis: 6),
            Theme(name: "Food", emojis: "đđđđđđđđ", color:"orange", numPairsOfEmojis: 8)
        ]
    }
    
    func theme(at index:Int) -> Theme {
        let safeIdx = min(max(0, index), themes.count - 1)
        return themes[safeIdx]
    }
    
    func addTheme(_ theme:Theme) {
        addTheme(name: theme.name, emojis: theme.emojis, color: theme.color)
    }
    
    func addTheme(name: String, emojis: String, color: String) {
        themes.append(Theme(name: name, emojis: emojis, color: color, numPairsOfEmojis: emojis.count))
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
